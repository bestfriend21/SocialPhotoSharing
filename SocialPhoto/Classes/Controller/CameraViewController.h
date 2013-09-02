//
//  IFFiltersViewController.h
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageAdjustView.h"

#import "GPUImageGaussianSelectiveBlurFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageContrastFilter.h"
#import "GPUImageSaturationFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageSharpenFilter.h"
#import "GPUImageFilterPipeline.h"

#import "InstaFilters.h"
#import "UIImage+IF.h"
#import "GPUImageView.h"
#import "GPUImagePicture.h"
#import "BlurOverlayView.h"
#import "IFAppDelegate.h"

@interface CameraViewController : UIViewController<ImageAdjustViewDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IFVideoCameraDelegate>
{
    BOOL isStatic;
    BOOL hasBlur;
    BOOL hasLux;
    BOOL showAdjustView;
    BOOL selectedFilter;
    BOOL selectedAlbum;
    
    ImageAdjustView               *mAdjustView;
    
    GPUImageBrightnessFilter      *mBrightnessFilter;
    GPUImageContrastFilter        *mContrastFilter;
    GPUImageSaturationFilter      *mSaturationFilter;
    GPUImageOutput<GPUImageInput> *mBlurFilter;
    GPUImagePicture               *mStaticPicture;
    GPUImageSharpenFilter         *filter;
    GPUImageFilterPipeline        *mFilterPipeLine;
    GPUImageRotationMode           mRotationMode;
    
    UIImageView                   *mFrameImageView;
    UIImageOrientation            mStaticPictureOriginalOrientation;
    UIImageView                   *focusView;
    
    IBOutlet UIPanGestureRecognizer        *mPangesture;
    IBOutlet UIPinchGestureRecognizer      *mPingesture;
    IBOutlet UITapGestureRecognizer        *mTapgesture;
    
    IBOutlet UIButton                      *mDoneButton;
    
    double                        mContrast;
    double                        mBrightness;
    double                        mSaturation;
    
    NSInteger                     mRotationState;
    
    __block UIImagePickerController *mAlbumPicker;
}

@property (nonatomic, unsafe_unretained) BOOL shouldLaunchAsAVideoRecorder;
@property (nonatomic, unsafe_unretained) BOOL shouldLaunchAshighQualityVideo;
@property (nonatomic, unsafe_unretained) BOOL isFiltersTableViewVisible;

@property (nonatomic, strong) IFVideoCamera *mVideoCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *mBlurFilter;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *mLuxFilter;
@property (nonatomic, strong) IBOutlet GPUImageView *mImageView;

@property (nonatomic, strong) UITableView *filtersTableView;
@property (nonatomic, strong) IBOutlet UIView *filterTableViewContainerView;

@property (nonatomic, strong) UIImageView *blueDotImageView;
@property (nonatomic, strong) UIView      *cameraTrayImageView;

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *photoAlbumButton;
@property (nonatomic, strong) IBOutlet UIButton *shootButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelAlbumPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton *confirmAlbumPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton *toggleCameraButton;
@property (nonatomic, strong) IBOutlet UIButton *toggleFlashButton;
@property (nonatomic, strong) IBOutlet UIButton *brightnessButton;
@property (nonatomic, strong) IBOutlet UIButton *frameButton;
@property (nonatomic, strong) IBOutlet UIButton *blurButton;
@property (nonatomic, strong) IBOutlet UIButton *luxButton;
@property (nonatomic, strong) IBOutlet UIButton *rotateButton;

@property (nonatomic, strong) BlurOverlayView *blurOverlayView;
@property (nonatomic, unsafe_unretained) IFFilterType currentType;

@property (nonatomic, unsafe_unretained) BOOL isInVideoRecorderMode;
@property (nonatomic, unsafe_unretained) BOOL isHighQualityVideo;


- (IBAction)backButtonPressed:(id)sender;
- (IBAction)toggleFiltersButtonPressed:(id)sender;
- (IBAction)photoAlbumButtonPressed:(id)sender;
- (IBAction)shootButtonPressed:(id)sender;
- (IBAction)cancelAlbumPhotoButtonPressed:(id)sender;
- (IBAction)confirmAlbumPhotoButtonPressed:(id)sender;
- (IBAction)frameButtonClicked:(id)sender;
- (IBAction)brightnessButtonClicked:(id)sender;
- (IBAction)blurButtonClicked:(id)sender;
- (IBAction)luxButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@end
