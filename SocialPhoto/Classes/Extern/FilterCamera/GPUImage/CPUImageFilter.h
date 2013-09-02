#import "CPUImageOutput.h"
#import <UIKit/UIKit.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

extern NSString *const kGPUImageVertexShaderString;

@interface CPUImageFilter : CPUImageOutput <CPUImageInput>
{
    GLuint filterSourceTexture, filterSourceTexture2, filterOutputTexture;
    
    CLProgram *filterProgram;

    CGSize currentFilterSize;
}

// Initialization and teardown
- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
- (id)initWithFragmentShaderFromFile:(NSString *)fragmentShaderFilename;

// Still image processing
- (UIImage *)imageFromCurrentlyProcessedOutput;
- (UIImage *)imageByFilteringImage:(UIImage *)imageToFilter;

// Rendering
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;

// Input parameters
- (void)setInteger:(GLint)newInteger forUniform:(NSString *)uniformName;
- (void)setFloat:(GLfloat)newFloat forUniform:(NSString *)uniformName;
- (void)setSize:(CGSize)newSize forUniform:(NSString *)uniformName;
- (void)setPoint:(CGPoint)newPoint forUniform:(NSString *)uniformName;
- (void)setFloatVec3:(GLfloat *)newVec3 forUniform:(NSString *)uniformName;
- (void)setFloatVec4:(GLfloat *)newVec4 forUniform:(NSString *)uniformName;

@end