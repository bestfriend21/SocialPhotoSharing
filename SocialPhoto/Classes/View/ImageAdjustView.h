//
//  ImageAdjustView.h
//  SocialPhotoSharing
//
//  Created by Wang YuPing on 8/18/13.
//  Copyright (c) 2013 wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageAdjustViewDelegate <NSObject>

- (void) changeSaturationSlider : (float) value;
- (void) changeBrightnessSlider : (float) value;
- (void) changeContrastSlider : (float) value;
- (void) hideAdjustView;
- (void) resetSBC;

@end

@interface ImageAdjustView : UIView
{
    IBOutlet UISlider       *mSaturationSlider;
    IBOutlet UISlider       *mBrightnessSlider;
    IBOutlet UISlider       *mContrastSlider;
    IBOutlet UIImageView    *mFirstBackImageView;
    IBOutlet UIImageView    *mSecondBackImageView;
}

@property (nonatomic, assign) id<ImageAdjustViewDelegate>   delegate;

- (void) initAdjustView;
- (void) setAdjustBrightness : (double) brightness contrast : (double) contrast saturation : (double) saturation;

@end
