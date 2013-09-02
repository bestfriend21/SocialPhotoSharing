#import "CPUImageFilter.h"

typedef enum { kCPUImageRotateLeft, kCPUImageRotateRight, kCPUImageFlipVertical, kCPUImageFlipHorizonal} CPUImageRotationMode;

@interface CPUImageRotationFilter : CPUImageFilter
{
    CPUImageRotationMode rotationMode;
}

// Initialization and teardown
- (id)initWithRotation:(CPUImageRotationMode)newRotationMode;

@end
