//
//  ImageAdjustView.m
//  SocialPhotoSharing
//
//  Created by Wang YuPing on 8/18/13.
//  Copyright (c) 2013 wang. All rights reserved.
//

#import "ImageAdjustView.h"

@implementation ImageAdjustView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) initAdjustView
{
    mFirstBackImageView.image = [[UIImage imageNamed:@"backhud.png"] stretchableImageWithLeftCapWidth:40 topCapHeight:33];
    mSecondBackImageView.image = [[UIImage imageNamed:@"backhud.png"] stretchableImageWithLeftCapWidth:40 topCapHeight:33];
}

- (IBAction) closeButtonClicked : (id) sender
{
    if ( self.delegate != nil ) {
        [self.delegate hideAdjustView];
    }
}

- (IBAction) resetButtonClicked : (id) sender
{
    if ( self.delegate != nil ) {
        [self.delegate resetSBC];
    }
    
    mBrightnessSlider.value = 0;
    mContrastSlider.value = 1;
    mSaturationSlider.value = 1;
}

- (IBAction) slideValueChanged : (id) sender
{
    UISlider *slider = (UISlider *)sender;
    NSInteger tag = slider.tag;
    
    if ( self.delegate != nil ) {
     
        if ( tag == 1000 ) {
            [self.delegate changeSaturationSlider:slider.value];
        } else if ( tag == 1001 ) {
            [self.delegate changeBrightnessSlider:slider.value];
        } else if ( tag == 1002 ) {
            [self.delegate changeContrastSlider:slider.value];
        }

    }
}

- (void) setAdjustBrightness : (double) brightness contrast : (double) contrast saturation : (double) saturation
{
    mBrightnessSlider.value = brightness;
    mContrastSlider.value = contrast;
    mSaturationSlider.value = saturation;
}

@end
