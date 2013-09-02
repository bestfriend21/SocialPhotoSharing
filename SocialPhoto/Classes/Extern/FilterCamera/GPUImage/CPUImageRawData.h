#import <Foundation/Foundation.h>
#import "CPUImageOpenGLESContext.h"

struct GPUByteColorVector {
    GLubyte red;
    GLubyte green;
    GLubyte blue;
    GLubyte alpha;
};
typedef struct GPUByteColorVector GPUByteColorVector;

@protocol CPUImageRawDataProcessor;

@interface CPUImageRawData : NSObject <CPUImageInput>

@property(readwrite, unsafe_unretained, nonatomic) id<CPUImageRawDataProcessor> delegate;
@property(readonly) GLubyte *rawBytesForImage;

// Initialization and teardown
- (id)initWithImageSize:(CGSize)newImageSize;

// Data access
- (GPUByteColorVector)colorAtLocation:(CGPoint)locationInImage;

@end

@protocol CPUImageRawDataProcessor
- (void)newImageFrameAvailableFromDataSource:(CPUImageRawData *)rawDataSource;
@end