#import "CPUImageOpenGLESContext.h"
#import "CLProgram.h"

@interface CPUImageOutput : NSObject
{
    NSMutableArray *targets, *targetTextureIndices;
    
    GLuint outputTexture;
    CGSize inputTextureSize, cachedMaximumOutputSize;
}

@property(readwrite, nonatomic) BOOL shouldSmoothlyScaleOutput;

// Managing targets
- (void)addTarget:(id<CPUImageInput>)newTarget;
- (void)removeTarget:(id<CPUImageInput>)targetToRemove;
- (void)removeAllTargets;

// Manage the output texture
- (void)initializeOutputTexture;
- (void)deleteOutputTexture;

@end
