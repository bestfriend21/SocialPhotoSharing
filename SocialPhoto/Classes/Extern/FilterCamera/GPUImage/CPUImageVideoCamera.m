#import "CPUImageVideoCamera.h"

#pragma mark -
#pragma mark Private methods and instance variables

@interface CPUImageVideoCamera () 
{
	AVCaptureDeviceInput *videoInput;
	AVCaptureVideoDataOutput *videoOutput;
}

@end

@implementation CPUImageVideoCamera
@synthesize inputCamera = _inputCamera;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [self initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack]))
    {
		return nil;
    }

    return self;
}

- (BOOL)isFrontFacingCameraPresent;
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == AVCaptureDevicePositionFront)
			return YES;
	}
	
	return NO;
}

- (void)rotateCamera
{
	if (self.frontFacingCameraPresent == NO)
		return;
	
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition currentCameraPosition = [[videoInput device] position];
    
    if (currentCameraPosition == AVCaptureDevicePositionBack)
    {
        currentCameraPosition = AVCaptureDevicePositionFront;
    }
    else
    {
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == currentCameraPosition)
		{
			backFacingCamera = device;
		}
	}
    
    newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    
    if (newVideoInput != nil)
    {
        [captureSession beginConfiguration];
        
        [captureSession removeInput:videoInput];
        if ([captureSession canAddInput:newVideoInput])
        {
            [captureSession addInput:newVideoInput];
            videoInput = newVideoInput;
        }
        else
        {
            [captureSession addInput:videoInput];
        }
        //captureSession.sessionPreset = oriPreset;
        [captureSession commitConfiguration];
    }
    
    _inputCamera = backFacingCamera;
//    [self setOutputImageOrientation:_outputImageOrientation];
}


- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition; 
{
	if (!(self = [super init]))
    {
		return nil;
    }
    
    runBenchmark = NO;
    
    if ([CPUImageVideoCamera supportsFastTextureUpload])
    {
        [CPUImageOpenGLESContext useImageProcessingContext];
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, CFBridgingRelease((__bridge void *)[[CPUImageOpenGLESContext sharedImageProcessingOpenGLESContext] context]), NULL, &coreVideoTextureCache);
        if (err) 
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d");
        }
        
        // Need to remove the initially created texture
        [self deleteOutputTexture];
    }

	
    
    _inputCamera = nil;
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == cameraPosition)
		{
			_inputCamera = device;
		}
	}
    
    if (!_inputCamera) {
        return nil;
    }
    	
	// Create the capture session
	captureSession = [[AVCaptureSession alloc] init];
	
    [captureSession beginConfiguration];

	// Add the video input	
	NSError *error = nil;
	videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_inputCamera error:&error];
	if ([captureSession canAddInput:videoInput]) 
	{
		[captureSession addInput:videoInput];
	}
    
    
	
	// Add the video frame output	
	videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES];

	[videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    //	dispatch_queue_t videoQueue = dispatch_queue_create("com.sunsetlakesoftware.colortracking.videoqueue", NULL);
    //	[videoOutput setSampleBufferDelegate:self queue:videoQueue];

	[videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
	if ([captureSession canAddOutput:videoOutput])
	{
		[captureSession addOutput:videoOutput];
	}
	else
	{
		NSLog(@"Couldn't add video output");
	}
    
    [captureSession setSessionPreset:sessionPreset];
    [captureSession commitConfiguration];

//    inputTextureSize
    	
	return self;
}

- (void)dealloc 
{
    [self stopCameraCapture];
//    [videoOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];    
    
    [captureSession removeInput:videoInput];
    [captureSession removeOutput:videoOutput];

    if ([CPUImageVideoCamera supportsFastTextureUpload])
    {
#warning check this part again
//        CFRelease(coreVideoTextureCache);
    }
}

#pragma mark -
#pragma mark Manage fast texture upload

+ (BOOL)supportsFastTextureUpload;
{
    return (CVOpenGLESTextureCacheCreate != NULL);
}

#pragma mark -
#pragma mark Manage the camera video stream

- (void)startCameraCapture;
{
    if (![captureSession isRunning])
	{
		[captureSession startRunning];
	};
}

- (void)stopCameraCapture;
{
    if ([captureSession isRunning])
    {
        [captureSession stopRunning];
    }
}

#pragma mark -
#pragma mark Benchmarking

- (CGFloat)averageFrameDurationDuringCapture;
{
    NSLog(@"Number of frames: %d", numberOfFramesCaptured);
    return (totalFrameTimeDuringCapture / (CGFloat)numberOfFramesCaptured) * 1000.0;
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = CVPixelBufferGetWidth(cameraFrame);
    int bufferHeight = CVPixelBufferGetHeight(cameraFrame);

    if ([CPUImageVideoCamera supportsFastTextureUpload])
    {
        CVPixelBufferLockBaseAddress(cameraFrame, 0);

        [CPUImageOpenGLESContext useImageProcessingContext];
        CVOpenGLESTextureRef texture = NULL;
        CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_RGBA, bufferWidth, bufferHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &texture);
                
        if (!texture || err) {
            NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);  
            return;
        }
        
        outputTexture = CVOpenGLESTextureGetName(texture);
        glBindTexture(CVOpenGLESTextureGetTarget(texture), outputTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        for (id<CPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            [currentTarget setInputTexture:outputTexture atIndex:[[targetTextureIndices objectAtIndex:indexOfObject] integerValue]];

            [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight)];
            [currentTarget newFrameReady];
        }
        
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);

//        glBindTexture(outputTexture, 0);
        
        // Flush the CVOpenGLESTexture cache and release the texture
        CVOpenGLESTextureCacheFlush(coreVideoTextureCache, 0);
        CFRelease(texture);
        outputTexture = 0;
        
        if (runBenchmark)
        {
            CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
            totalFrameTimeDuringCapture += currentFrameTime;
            numberOfFramesCaptured++;
            //        NSLog(@"Average frame time : %f ms", 1000.0 * (totalFrameTimeDuringCapture / numberOfFramesCaptured));
            //        NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
        }
    }
    else
    {
        // Upload to texture
        CVPixelBufferLockBaseAddress(cameraFrame, 0);
        
        glBindTexture(GL_TEXTURE_2D, outputTexture);
        // Using BGRA extension to pull in video frame data directly
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bufferWidth, bufferHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(cameraFrame));
        
        for (id<CPUImageInput> currentTarget in targets)
        {
            [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight)];
            [currentTarget newFrameReady];
        }
        
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
        
        if (runBenchmark)
        {
            CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
            totalFrameTimeDuringCapture += currentFrameTime;
            numberOfFramesCaptured++;
            //        NSLog(@"Average frame time : %f ms", 1000.0 * (totalFrameTimeDuringCapture / numberOfFramesCaptured));
            //        NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
        }
    }    
}

#pragma mark -
#pragma mark Accessors

@synthesize captureSession;
@synthesize runBenchmark;

@end
