#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>

@interface CPUImageOpenGLESContext : NSObject
{
    EAGLContext *context;
}

@property(readonly) EAGLContext *context;

+ (CPUImageOpenGLESContext *)sharedImageProcessingOpenGLESContext;
+ (void)useImageProcessingContext;
+ (GLint)maximumTextureSizeForThisDevice;
+ (GLint)maximumTextureUnitsForThisDevice;

- (void)presentBufferForDisplay;

@end

@protocol CPUImageInput
- (void)newFrameReady;
- (void)setInputTexture:(GLuint)newInputTexture atIndex:(NSInteger)textureIndex;
- (NSInteger)nextAvailableTextureIndex;
- (void)setInputSize:(CGSize)newSize;
- (CGSize)maximumOutputSize;
@end