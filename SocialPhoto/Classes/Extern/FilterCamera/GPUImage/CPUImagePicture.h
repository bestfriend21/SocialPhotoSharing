#import <UIKit/UIKit.h>
#import "CPUImageOutput.h"


@interface CPUImagePicture : CPUImageOutput
{
    UIImage *imageSource;
}

// Initialization and teardown
- (id)initWithImage:(UIImage *)newImageSource;
- (id)initWithImage:(UIImage *)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput;

// Image rendering
- (void)processImage;

@end
