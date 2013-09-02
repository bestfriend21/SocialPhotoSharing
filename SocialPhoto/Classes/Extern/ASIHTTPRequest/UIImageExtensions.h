//
//  UIImageExtensions.h
//  LMKMaster
//
//  Created by Christopher Luu on 7/26/10.
//  Copyright 2010 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Resize)

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality;
+ (NSData *) getCompressedData : (UIImage  *) image;
+ (UIImage *) getCompressedImage : (UIImage  *) image;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize : (UIImage *) sourceImage;

@end
