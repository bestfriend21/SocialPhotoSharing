#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "CPUImageOpenGLESContext.h"
#import "CPUImageOutput.h"

@interface CPUImageMovie : CPUImageOutput {
  CVPixelBufferRef _currentBuffer;
}

@property (readwrite, retain) NSURL *url;

-(id)initWithURL:(NSURL *)url;
-(void)startProcessing;
-(void)endProcessing;

@end
