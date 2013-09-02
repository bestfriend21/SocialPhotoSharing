//
//  IFFiltersViewController.m
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#define kFilterImageViewTag 9999
#define kFilterImageViewContainerViewTag 9998
#define kBlueDotImageViewOffset 25.0f
#define kFilterCellHeight 72.0f
#define kBlueDotAnimationTime 0.2f
#define kFilterTableViewAnimationTime 0.2f
#define kCPUImageViewAnimationOffset 27.0f

#import "CameraViewController.h"

@implementation CameraViewController

@synthesize backButton;
@synthesize isFiltersTableViewVisible;
@synthesize filtersTableView;
@synthesize filterTableViewContainerView;
@synthesize blueDotImageView;
@synthesize cameraTrayImageView;
@synthesize mVideoCamera;
@synthesize photoAlbumButton;
@synthesize shootButton;
@synthesize currentType;
@synthesize cancelAlbumPhotoButton;
@synthesize confirmAlbumPhotoButton;
@synthesize shouldLaunchAsAVideoRecorder;
@synthesize isInVideoRecorderMode;
@synthesize shouldLaunchAshighQualityVideo;
@synthesize isHighQualityVideo;
@synthesize blurOverlayView;
@synthesize mBlurFilter;
@synthesize mLuxFilter;
@synthesize mImageView;

#pragma mark - Video Camera Delegate
- (void)IFVideoCameraWillStartCaptureStillImage:(IFVideoCamera *)videoCamera {
    
    self.shootButton.enabled = NO;
    
    if (self.isInVideoRecorderMode == NO) {
        self.photoAlbumButton.hidden = YES;
    }
    
    [self.cancelAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"img_btn_back" ofType:@"png"]] forState:UIControlStateNormal];
    [self.confirmAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraAcceptDisabled" ofType:@"png"]] forState:UIControlStateNormal];
    
    self.cancelAlbumPhotoButton.hidden = NO;
    self.rotateButton.hidden = NO;
    self.frameButton.hidden = NO;
    self.brightnessButton.hidden = NO;
    self.blurButton.hidden = NO;
    self.luxButton.hidden = NO;
    
    self.backButton.hidden = YES;
    self.toggleFlashButton.hidden = YES;
    self.toggleCameraButton.hidden = YES;
}

- (void)IFVideoCameraDidFinishCaptureStillImage:(IFVideoCamera *)videoCamera {
    
    [self.cancelAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"img_btn_back" ofType:@"png"]] forState:UIControlStateNormal];
    [self.confirmAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraAccept" ofType:@"png"]] forState:UIControlStateNormal];
    
    self.shootButton.hidden = YES;
    self.shootButton.enabled = YES;
    
    mVideoCamera.cpuImageView_HD.hidden = YES;
   
    [mDoneButton setHidden:NO];
    
    [self removeAllTarget];
    
    mStaticPicture = [[GPUImagePicture alloc] initWithImage:[mVideoCamera getFilteredImage]  smoothlyScaleOutput:YES];
    
    [self prepareStaticFilter];
}

- (void)IFVideoCameraDidSaveStillImage:(IFVideoCamera *)videoCamera {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your image was saved in Camera Roll." delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
    [alertView show];
    
    [self.cancelAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"img_btn_back" ofType:@"png"]] forState:UIControlStateNormal];
    [self.confirmAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraAccept" ofType:@"png"]] forState:UIControlStateNormal];
    self.cancelAlbumPhotoButton.enabled = YES;
    self.confirmAlbumPhotoButton.enabled = YES;
    
    [self cancelAlbumPhotoButtonPressed:nil];
}

- (BOOL)canIFVideoCameraStartRecordingMovie:(IFVideoCamera *)videoCamera {
    if (shootButton.hidden == YES) {
        return NO;
    } else if (self.mVideoCamera.isRecordingMovie == YES) {
        return NO;
    } else {
        return YES;
    }
}

- (void)IFVideoCameraWillStartProcessingMovie:(IFVideoCamera *)videoCamera {
    NSLog(@" - 1 -");
    [self.shootButton setTitle:@"Processing" forState:UIControlStateNormal];
    self.shootButton.enabled = NO;
}

- (void)IFVideoCameraDidFinishProcessingMovie:(IFVideoCamera *)videoCamera {
    NSLog(@" - 2 -");
    
    self.shootButton.enabled = YES;
    [self.shootButton setTitle:@"Record" forState:UIControlStateNormal];
    
}

#pragma mark - Process Album Photo from Image Pick

- (UIImage *)processAlbumPhoto:(NSDictionary *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    float original_width = originalImage.size.width;
    float original_height = originalImage.size.height;
    
    if ([info objectForKey:UIImagePickerControllerCropRect] == nil) {
        if (original_width < original_height) {
            /*
             UIGraphicsBeginImageContext(mask.size);
             [ori drawAtPoint:CGPointMake(0,0)];
             [mask drawAtPoint:CGPointMake(0,0)];
             
             UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             return newImage;
             */
            return nil;
        } else {
            return nil;
        }
    } else {
        CGRect crop_rect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        float crop_width = crop_rect.size.width;
        float crop_height = crop_rect.size.height;
        float crop_x = crop_rect.origin.x;
        float crop_y = crop_rect.origin.y;
        float remaining_width = original_width - crop_x;
        float remaining_height = original_height - crop_y;
        
        // due to a bug in iOS
        if ( (crop_x + crop_width) > original_width) {
            NSLog(@" - a bug in x direction occurred! now we fix it!");
            crop_width = original_width - crop_x;
        }
        if ( (crop_y + crop_height) > original_height) {
            NSLog(@" - a bug in y direction occurred! now we fix it!");
            
            crop_height = original_height - crop_y;
        }
        
        float crop_longer_side = 0.0f;
        
        if (crop_width > crop_height) {
            crop_longer_side = crop_width;
        } else {
            crop_longer_side = crop_height;
        }
        //NSLog(@" - ow = %g, oh = %g", original_width, original_height);
        //NSLog(@" - cx = %g, cy = %g, cw = %g, ch = %g", crop_x, crop_y, crop_width, crop_height);
        //NSLog(@" - cls=%g, rw = %g, rh = %g", crop_longer_side, remaining_width, remaining_height);
        if ( (crop_longer_side <= remaining_width) && (crop_longer_side <= remaining_height) ) {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, crop_longer_side, crop_longer_side)];
            
            return tmpImage;
        } else if ( (crop_longer_side <= remaining_width) && (crop_longer_side > remaining_height) ) {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, crop_longer_side, remaining_height)];
            
            float new_y = (crop_longer_side - remaining_height) / 2.0f;
            //UIGraphicsBeginImageContext(CGSizeMake(crop_longer_side, crop_longer_side));
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(crop_longer_side, crop_longer_side), YES, 1.0f);
            [tmpImage drawAtPoint:CGPointMake(0.0f,new_y)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        } else if ( (crop_longer_side > remaining_width) && (crop_longer_side <= remaining_height) ) {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, remaining_width, crop_longer_side)];
            
            float new_x = (crop_longer_side - remaining_width) / 2.0f;
            //UIGraphicsBeginImageContext(CGSizeMake(crop_longer_side, crop_longer_side));
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(crop_longer_side, crop_longer_side), YES, 1.0f);
            [tmpImage drawAtPoint:CGPointMake(new_x,0.0f)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        } else {
            return nil;
        }
        
    }
}

#pragma mark - UIImagePicker Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    isStatic = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self.cancelAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"img_btn_back" ofType:@"png"]] forState:UIControlStateNormal];
    [self.confirmAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraAcceptDisabled" ofType:@"png"]] forState:UIControlStateNormal];
    
    selectedAlbum = YES;
    
    
    self.mVideoCamera.rawImage = [self processAlbumPhoto:info];
    [self.mVideoCamera switchFilter:currentType];
    
    self.photoAlbumButton.hidden = YES;
    self.cancelAlbumPhotoButton.hidden = NO;
    self.rotateButton.hidden = NO;
    self.frameButton.hidden = NO;
    self.brightnessButton.hidden = NO;
    self.blurButton.hidden = NO;
    self.luxButton.hidden = NO;
    
    self.backButton.hidden = YES;
    self.toggleFlashButton.hidden = YES;
    self.toggleCameraButton.hidden = YES;

    [shootButton setHidden:YES];
    [mDoneButton setHidden:NO];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self dismissViewControllerAnimated:YES completion:^(){
        
        [self.mVideoCamera startCameraCapture];
        
    }];
}

#pragma mark - Filters TableView Delegate & Datasource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kFilterCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.currentType = [indexPath row];
    
    selectedFilter = YES;
    
    [self.mVideoCamera switchFilter:[indexPath row]];
    
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGRect tempRect = self.blueDotImageView.frame;
    tempRect.origin.y = cellRect.origin.y + kBlueDotImageViewOffset;
    
    [UIView animateWithDuration:kBlueDotAnimationTime animations:^() {

        self.blueDotImageView.frame = tempRect;

    } completion:^(BOOL finished){
        // do nothing
    }];
    
    
    switch ([indexPath row]) {
        case 0: {
            mFrameImageView.image = nil;
            break;
        }
        case 1: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"amaroBorder" ofType:@"png"]];
            break;
        }
        case 2: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"riseBorder" ofType:@"png"]];
            break;
        }
        case 3: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hudsonBorder" ofType:@"png"]];
            break;
        }
        case 4: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"XPro2Border" ofType:@"png"]];
            break;
        }
        case 5: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraBorder" ofType:@"png"]];
            break;
        }
        case 6: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lomoBorder" ofType:@"png"]];
            break;
        }
        case 7: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdBorder" ofType:@"png"]];
            break;
        }
        case 8: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroBorder" ofType:@"png"]];
            break;
        }
        case 9: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraBorder" ofType:@"png"]];
            break;
        }
        case 10: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanBorder" ofType:@"png"]];
            break;
        }
        case 11: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraBorder" ofType:@"png"]];
            break;
        }
        case 12: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"waldenBorder" ofType:@"png"]];
            break;
        }
        case 13: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeBorder" ofType:@"png"]];
            break;
        }
        case 14: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraBorder" ofType:@"png"]];
            break;
        }
        case 15: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nashvilleBorder" ofType:@"png"]];
            break;
        }
        case 16: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraBorder" ofType:@"png"]];
            break;
        }
        case 17: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kelvinBorder" ofType:@"png"]];
            break;
        }
            
        case 18: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mayfairBorder" ofType:@"png"]];
            break;
        }
            
        case 19: {
            mFrameImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"willowBorder" ofType:@"png"]];
            break;
        }

            
        default: {
            mFrameImageView.hidden = YES;
            
            break;
        }
    }

    
    if (([indexPath row] != [[[tableView indexPathsForVisibleRows] objectAtIndex:0] row]) && ([indexPath row] != [[[tableView indexPathsForVisibleRows] lastObject] row])) {
        
        return;
    }
    
    if ([indexPath row] == [[[tableView indexPathsForVisibleRows] objectAtIndex:0] row]) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *filtersTableViewCellIdentifier = @"filtersTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: filtersTableViewCellIdentifier];
    UIImageView *filterImageView;
    UIView *filterImageViewContainerView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:filtersTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, -7.5, 57, 72)];
        filterImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
        filterImageView.tag = kFilterImageViewTag;
        
        filterImageViewContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 57, 72)];
        filterImageViewContainerView.tag = kFilterImageViewContainerViewTag;
        [filterImageViewContainerView addSubview:filterImageView];
        
        [cell.contentView addSubview:filterImageViewContainerView];
    } else {
        filterImageView = (UIImageView *)[cell.contentView viewWithTag:kFilterImageViewTag];
    }
    
    switch ([indexPath row]) {
        case 0: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileNormal" ofType:@"png"]];
            
            break;
        }
        case 1: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileAmaro" ofType:@"png"]];
            
            break;
        }
        case 2: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileRise" ofType:@"png"]];
            
            break;
        }
        case 3: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileHudson" ofType:@"png"]];
            
            break;
        }
        case 4: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileXpro2" ofType:@"png"]];
            
            break;
        }
        case 5: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileSierra" ofType:@"png"]];
            
            break;
        }
        case 6: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileLomoFi" ofType:@"png"]];
            
            break;
        }
        case 7: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileEarlybird" ofType:@"png"]];
            
            break;
        }
        case 8: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileSutro" ofType:@"png"]];
            
            break;
        }
        case 9: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileToaster" ofType:@"png"]];
            
            break;
        }
        case 10: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileBrannan" ofType:@"png"]];
            
            break;
        }
        case 11: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileInkwell" ofType:@"png"]];
            
            break;
        }
        case 12: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileWalden" ofType:@"png"]];
            
            break;
        }
        case 13: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileHefe" ofType:@"png"]];
            
            break;
        }
        case 14: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileValencia" ofType:@"png"]];
            
            break;
        }
        case 15: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileNashville" ofType:@"png"]];
            
            break;
        }
        case 16: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTile1977" ofType:@"png"]];
            
            break;
        }
        case 17: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileLordKelvin" ofType:@"png"]];
            break;
        }
            
        case 18: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileLordKelvin" ofType:@"png"]];
            break;
        }
            
        case 19: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileLordKelvin" ofType:@"png"]];
            break;
        }
            
        default: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileNormal" ofType:@"png"]];
            
            break;
        }
    }
    
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

#pragma mark - Other

- (void) removeAllTarget
{
    [mStaticPicture removeAllTargets];
    [mBlurFilter removeAllTargets];
    [mContrastFilter removeAllTargets];
    [mBrightnessFilter removeAllTargets];
    [mSaturationFilter removeAllTargets];
    [mLuxFilter removeAllTargets];
}

- (void) updatePreview : (NSNotification *) notification
{
    
    if ( mImageView.hidden == NO && selectedFilter == YES ) {
        
        [mDoneButton setHidden:NO];
        
        [self removeAllTarget];
        
        if ( mStaticPicture != nil )
            mStaticPicture = nil;
        
        mStaticPicture = [[GPUImagePicture alloc] initWithImage:notification.object  smoothlyScaleOutput:YES];
        
        [self prepareStaticFilter];

        selectedFilter = NO;
        
    } else if ( selectedAlbum == YES ) {
        
        [mDoneButton setHidden:NO];
        
        [self removeAllTarget];
        
        if ( mStaticPicture != nil )
            mStaticPicture = nil;
        
        mStaticPicture = [[GPUImagePicture alloc] initWithImage:notification.object  smoothlyScaleOutput:YES];
        
        [self prepareStaticFilter];
        
        
        selectedAlbum = NO;
        
        if ( mAlbumPicker != nil ) {
            [mAlbumPicker dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void) initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePreview:) name:@"updatedFilterImage" object:nil];
}

- (void) initBSHFilter
{
    if ( mBrightnessFilter == nil )
        mBrightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    
    if ( mContrastFilter == nil )
        mContrastFilter = [[GPUImageContrastFilter alloc] init];
    
    if ( mSaturationFilter == nil )
        mSaturationFilter = [[GPUImageSaturationFilter alloc] init];
    
    mBrightnessFilter.brightness = mBrightness;
    mContrastFilter.contrast = mContrast;
    mSaturationFilter.saturation = mSaturation;
}

- (void) prepareStaticFilter {

    [self initBSHFilter];
    
    if ( hasBlur ) {
        
        [mStaticPicture addTarget:mContrastFilter];
        [mContrastFilter addTarget:mBrightnessFilter];
        [mBrightnessFilter addTarget:mSaturationFilter];
        [mSaturationFilter addTarget:mBlurFilter];
        
        if ( hasLux == YES ) {
            [mBlurFilter addTarget:mLuxFilter];
            [mLuxFilter addTarget:self.mImageView];
        } else
            [mBlurFilter addTarget:self.mImageView];
        
    } else {
        
        [mStaticPicture addTarget:mContrastFilter];
        [mContrastFilter addTarget:mBrightnessFilter];
        [mBrightnessFilter addTarget:mSaturationFilter];
        
        if ( hasLux == YES ) {
            [mSaturationFilter addTarget:self.mLuxFilter];
            [mLuxFilter addTarget:mImageView];
        } else {
            [mSaturationFilter addTarget:mImageView];
        }
    }

    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    
    switch (mStaticPictureOriginalOrientation) {
            
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    
    if ( mRotationMode == kGPUImageNoRotation)
        [mImageView setInputRotation:imageViewRotationMode atIndex:0];
    else
        [mImageView setInputRotation:mRotationMode atIndex:0];
    
    [mStaticPicture processImage];
    
    mImageView.hidden = NO;
}

#pragma mark - Frame

- (void) updateFrame
{
    if ( self.frameButton.selected == YES ) {
        mFrameImageView.hidden = NO;
    } else {
        mFrameImageView.hidden = YES;
    }
}

#pragma mark - Flash Blur

-(void) showBlurOverlay:(BOOL)show{
    if(show){
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
            self.blurOverlayView.alpha = 0.6;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


-(void) flashBlurOverlay {
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.blurOverlayView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

#pragma mark - ImageAdjustView Delegate Method

- (void) resetSBC
{
    mBrightness = 0;
    mContrast = 1;
    mSaturation = 1;
    
    mSaturationFilter.saturation = mSaturation;
    mBrightnessFilter.brightness = mBrightness;
    mContrastFilter.contrast = mContrast;
    
    [mStaticPicture processImage];
}

- (void) changeSaturationSlider : (float) value
{
    mSaturation = value;
    
    mSaturationFilter.saturation = value;
    [mStaticPicture processImage];
}

- (void) changeBrightnessSlider : (float) value
{
    mBrightness = value;
    
    mBrightnessFilter.brightness = value;
    [mStaticPicture processImage];
}

- (void) changeContrastSlider : (float) value
{
    mContrast = value;
    
    mContrastFilter.contrast = value;
    
    [mStaticPicture processImage];
}

#pragma mark - UI Setup

- (void) showAdjustImageView : (BOOL) show
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    
    if ( show == YES ) {
        
        self.brightnessButton.selected = YES;
        showAdjustView = YES;
        
        CGRect rect = mAdjustView.frame;
        
        IFAppDelegate *appDelegate = (IFAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ( appDelegate.window.bounds.size.height == 568 )
            rect.origin.y = self.view.frame.size.height - mAdjustView.frame.size.height;
        else
            rect.origin.y = self.view.frame.size.height - 133;
        
        mAdjustView.frame = rect;
        
    } else {
        
        self.brightnessButton.selected = NO;
        showAdjustView = NO;
        
        CGRect rect = mAdjustView.frame;
        
        IFAppDelegate *appDelegate = (IFAppDelegate *) [[UIApplication sharedApplication] delegate];

        if ( appDelegate.window.bounds.size.height == 568 )
            rect.origin.y = 568;
        else
            rect.origin.y = 480;
        
        mAdjustView.frame = rect;
    }
    
    [mAdjustView setAdjustBrightness:mBrightness contrast:mContrast saturation:mSaturation];
    
    
    [UIView commitAnimations];
}

- (void) hideAdjustView
{
    [self showAdjustImageView:NO];
}

- (void) initAdjustView
{
    IFAppDelegate *appDelegate = (IFAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSArray *topLevelObjects;
    
    if ( appDelegate.window.bounds.size.height == 568 )
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ImageAdjustView~Four" owner:self options:nil];
    else
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ImageAdjustView" owner:self options:nil];        
    
    mAdjustView = [topLevelObjects objectAtIndex:0];
    mAdjustView.delegate = self;
    [self.view addSubview:mAdjustView];
    [mAdjustView initAdjustView];
    
    [mAdjustView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, mAdjustView.frame.size.height)];
}

- (void) initGesture
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isStatic = NO;
    
    [self initNotification];
    
    IFAppDelegate *appDelegate = (IFAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ( appDelegate.window.bounds.size.height == 568 ) {
        
        // If you create your views manually, you MUST override this method and use it to create your views.
        // If you use Interface Builder to create your views, then you must NOT override this method.
        
        
        self.isInVideoRecorderMode = self.shouldLaunchAsAVideoRecorder;
        self.isHighQualityVideo = self.shouldLaunchAshighQualityVideo;
        
        self.isFiltersTableViewVisible = YES;
        
        self.filtersTableView = [[UITableView alloc] initWithFrame:CGRectMake(124, -84, 72, 320) style:UITableViewStylePlain];
        self.filtersTableView.backgroundColor = [UIColor clearColor];
        self.filtersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.filtersTableView.showsVerticalScrollIndicator = NO;
        self.filtersTableView.delegate = self;
        self.filtersTableView.dataSource = self;
        self.filtersTableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
        
        self.blueDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-3, kBlueDotImageViewOffset + 4, 21, 11)];
        self.blueDotImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraSelectedFilter" ofType:@"png"]];
        self.blueDotImageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        [self.filtersTableView addSubview:self.blueDotImageView];
        
        self.cameraTrayImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 134)];
        self.cameraTrayImageView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:244.0f/255.0f alpha:1.0];
        
        [self.filterTableViewContainerView addSubview:self.cameraTrayImageView];
        [self.filterTableViewContainerView addSubview:self.filtersTableView];
        
        self.mVideoCamera = [[IFVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack highVideoQuality:self.isHighQualityVideo];
        self.mVideoCamera.delegate = self;
        
        self.mVideoCamera.cpuImageView.frame = CGRectMake(0, 60, self.mVideoCamera.cpuImageView.frame.size.width, self.mVideoCamera.cpuImageView.frame.size.height);
        
        [self.view addSubview:self.mVideoCamera.cpuImageView];
        
        // Do any additional setup after loading the view, typically from a nib.
        [self.mVideoCamera startCameraCapture];
        
        mImageView = [[GPUImageView alloc] init];
        mImageView.frame = CGRectMake(0, 60, self.mVideoCamera.cpuImageView.frame.size.width, mVideoCamera.cpuImageView.frame.size.height);
        [self.view addSubview:mImageView];
        mImageView.hidden = YES;

        self.blurOverlayView = [[BlurOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.mVideoCamera.cpuImageView.frame.size.width, self.mVideoCamera.cpuImageView.frame.size.height)];
        self.blurOverlayView.alpha = 0;
        [mImageView addSubview:self.blurOverlayView];
        
        [mImageView addGestureRecognizer:mPangesture];
        [mImageView addGestureRecognizer:mPingesture];
        
        hasBlur = NO;
        
        mFrameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, 320, self.mVideoCamera.cpuImageView.frame.size.height)];
        [self.view addSubview:mFrameImageView];
        
        [self updateFrame];
                        
    } else {
        
        
        // If you create your views manually, you MUST override this method and use it to create your views.
        // If you use Interface Builder to create your views, then you must NOT override this method.
        
        self.isInVideoRecorderMode = self.shouldLaunchAsAVideoRecorder;
        self.isHighQualityVideo = self.shouldLaunchAshighQualityVideo;
        
        self.isFiltersTableViewVisible = YES;
        
        self.filtersTableView = [[UITableView alloc] initWithFrame:CGRectMake(124, -90, 72, 320) style:UITableViewStylePlain];
        self.filtersTableView.backgroundColor = [UIColor clearColor];
        self.filtersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.filtersTableView.showsVerticalScrollIndicator = NO;
        self.filtersTableView.delegate = self;
        self.filtersTableView.dataSource = self;
        self.filtersTableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
        
        self.blueDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-3, kBlueDotImageViewOffset + 4, 21, 11)];
        self.blueDotImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraSelectedFilter" ofType:@"png"]];
        self.blueDotImageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        [self.filtersTableView addSubview:self.blueDotImageView];
        
        self.cameraTrayImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 66)];
        self.cameraTrayImageView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:244.0f/255.0f alpha:1.0];
        
        [self.filterTableViewContainerView addSubview:self.cameraTrayImageView];
        [self.filterTableViewContainerView addSubview:self.filtersTableView];
        
        self.mVideoCamera = [[IFVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack highVideoQuality:self.isHighQualityVideo];
        self.mVideoCamera.delegate = self;
        
        self.mVideoCamera.cpuImageView.frame = CGRectMake(0, 40, self.mVideoCamera.cpuImageView.frame.size.width, self.mVideoCamera.cpuImageView.frame.size.height);
        
        [self.view addSubview:self.mVideoCamera.cpuImageView];
        
        // Do any additional setup after loading the view, typically from a nib.
        [self.mVideoCamera startCameraCapture];
        
        hasBlur = NO;
        
        mImageView = [[GPUImageView alloc] init];
        mImageView.frame = CGRectMake(0, 40, mVideoCamera.cpuImageView.frame.size.width, mVideoCamera.cpuImageView.frame.size.height);
        [self.view addSubview:mImageView];
        mImageView.hidden = YES;
        
        [mImageView addGestureRecognizer:mPangesture];
        [mImageView addGestureRecognizer:mPingesture];
        
        self.blurOverlayView = [[BlurOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.mVideoCamera.cpuImageView.frame.size.width, self.mVideoCamera.cpuImageView.frame.size.height)];
        self.blurOverlayView.alpha = 0;
        [mImageView addSubview:self.blurOverlayView];
                
        mFrameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, self.mVideoCamera.cpuImageView.frame.size.width, self.mVideoCamera.cpuImageView.frame.size.height)];
        [self.view addSubview:mFrameImageView];
        
        [self updateFrame];
         
    }
    
    focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus-crosshair"]];
	[self.view addSubview:focusView];
	focusView.alpha = 0;
    
    [mVideoCamera.cpuImageView addGestureRecognizer:mTapgesture];
    
    
    mBrightness = 0;
    mContrast = 1;
    mSaturation = 1;
    
    [self initAdjustView];
    [self initBSHFilter];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction

- (IBAction)rotateButtonClicked:(id)sender
{    
    if ( mRotationState == 0 ) {
        mRotationMode = kGPUImageRotateRight;
        mRotationState = 1;
    } else if ( mRotationState == 1 ) {
        mRotationMode = kGPUImageRotate180;
        mRotationState = 2;
    } else if ( mRotationState == 2 ) {
        mRotationMode = kGPUImageRotateLeft;
        mRotationState = 3;
    } else {
        mRotationMode = kGPUImageNoRotation;
        mRotationState = 0;
    }
        
    [mImageView setInputRotation:mRotationMode atIndex:0];
    
    [mStaticPicture processImage];
}

- (IBAction) toggleFlash : (UIButton *) button {
    
    [button setSelected:!button.selected];
}

- (IBAction) switchCameraButtonPressed : (id) sender {
    
    [self.toggleCameraButton setEnabled:NO];
    [self.mVideoCamera rotateCamera];
    [self.toggleCameraButton setEnabled:YES];
    
    if ( [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && mVideoCamera ) {
        
        if ( [mVideoCamera.inputCamera hasFlash] && [mVideoCamera.inputCamera hasTorch] ) {
            [self.toggleFlashButton setEnabled:YES];
        } else {
            [self.toggleFlashButton setEnabled:NO];
        }
    }
    
}

- (IBAction) cancelAlbumPhotoButtonPressed : (id) sender {
    
    [mDoneButton setHidden:YES];
    
    isStatic = NO;
    
    self.frameButton.selected = NO;
    [self updateFrame];
    
    if ( self.blurButton.selected == YES )
        [self blurButtonClicked:nil];
    
    if ( self.luxButton.selected == YES )
        [self luxButtonClicked:nil];
    
    if ( self.brightnessButton.selected == YES )
        [self brightnessButtonClicked:nil];

    [self removeAllTarget];
    mStaticPicture = nil;
    mBlurFilter = nil;

    mRotationMode = kGPUImageNoRotation;
    mImageView.hidden = YES;
    mVideoCamera.cpuImageView_HD.hidden = YES;
    mVideoCamera.cpuImageView.hidden = NO;
    
    self.cancelAlbumPhotoButton.hidden = YES;
    self.confirmAlbumPhotoButton.hidden = YES;
    self.frameButton.hidden = YES;
    self.brightnessButton.hidden = YES;
    self.blurButton.hidden = YES;
    self.luxButton.hidden = YES;
    self.rotateButton.hidden = YES;
    
    self.cancelAlbumPhotoButton.hidden = YES;
    self.confirmAlbumPhotoButton.hidden = YES;
    self.shootButton.hidden = NO;
    self.toggleCameraButton.hidden = NO;
    self.toggleFlashButton.hidden = NO;
    self.backButton.hidden = NO;
    
    if (self.isInVideoRecorderMode == NO) {
        self.photoAlbumButton.hidden = NO;
    }
    
    mBrightness = 0;
    mContrast = 1;
    mSaturation = 1;
    
    [self.mVideoCamera cancelAlbumPhotoAndGoBackToNormal];
}

- (IBAction)confirmAlbumPhotoButtonPressed:(id)sender {
    [self.cancelAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraRejectDisabled" ofType:@"png"]] forState:UIControlStateNormal];
    [self.confirmAlbumPhotoButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"glCameraAcceptDisabled" ofType:@"png"]] forState:UIControlStateNormal];
    self.cancelAlbumPhotoButton.enabled = NO;
    self.confirmAlbumPhotoButton.enabled = NO;
    
    [self.mVideoCamera saveCurrentStillImage];
}

- (IBAction)frameButtonClicked:(id)sender
{
    UIButton *button = (UIButton *) sender;
    [button setSelected:!button.selected];
    
    [self updateFrame];
}

- (IBAction)brightnessButtonClicked:(id)sender
{
    _brightnessButton.selected = !_brightnessButton.selected;
    [self showAdjustImageView:!showAdjustView];
}

- (IBAction)blurButtonClicked:(id)sender
{
    [self.blurButton setEnabled:NO];
    
    if ( hasBlur ) {
        
        hasBlur = NO;
        [self showBlurOverlay:NO];
        [self.blurButton setSelected:NO];
        
    } else {
        
        if ( mBlurFilter == nil ) {
            mBlurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [(GPUImageGaussianSelectiveBlurFilter*)mBlurFilter setExcludeCircleRadius:80.0/320.0];
            [(GPUImageGaussianSelectiveBlurFilter*)mBlurFilter setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
            [(GPUImageGaussianSelectiveBlurFilter*)mBlurFilter setBlurSize:2.0f];
            [(GPUImageGaussianSelectiveBlurFilter*)mBlurFilter setAspectRatio:1.0f];
        }
        
        hasBlur = YES;
        [self.blurButton setSelected:YES];
        [self flashBlurOverlay];
    }

    [self removeAllTarget];
    
    [self prepareStaticFilter];
    
    [mStaticPicture processImage];

    
    [self.blurButton setEnabled:YES];
}

- (IBAction)luxButtonClicked:(id)sender
{
    [self.luxButton setEnabled:NO];
    
    if ( hasLux ) {
        
        hasLux = NO;
        [self.luxButton setSelected:NO];
        
    } else {
        
        if ( mLuxFilter == nil ) {
            self.mLuxFilter = [[GPUImageSharpenFilter alloc] init];
            GPUImageSharpenFilter *lux = (GPUImageSharpenFilter *) mLuxFilter;
            [lux setSharpness:-2.0];
        }
        
        hasLux = YES;
        [self.luxButton setSelected:YES];
    }
    
    [self removeAllTarget];
    [self prepareStaticFilter];
    
    [self.luxButton setEnabled:YES];
}

- (IBAction) photoAlbumButtonPressed : (id) sender {
    
    if ( mAlbumPicker != nil )
        mAlbumPicker = nil;
    
    mAlbumPicker = [[UIImagePickerController alloc] init];
    
    mAlbumPicker.delegate = self;
    mAlbumPicker.allowsEditing = YES;
    mAlbumPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:mAlbumPicker animated:YES completion:^(){
        // do nothing
        
    }];

}

- (IBAction) shootButtonPressed : (id) sender {
    
    isStatic = YES;
    
    if (self.isInVideoRecorderMode == YES) {
        if (self.mVideoCamera.isRecordingMovie == NO) {
            NSLog(@" - starts...");
            
            [self.shootButton setTitle:@"STOP" forState:UIControlStateNormal];
            
            self.filtersTableView.userInteractionEnabled = NO;
            if (self.isFiltersTableViewVisible == YES) {
                [self toggleFiltersButtonPressed:nil];
            }
            
            [self.mVideoCamera startRecordingMovie];
        } else {
            NSLog(@" - stops...");
            [self.mVideoCamera stopRecordingMovie];
            self.filtersTableView.userInteractionEnabled = YES;
            
        }
    } else {
        
        if ( _toggleFlashButton.selected && [mVideoCamera.inputCamera hasTorch] ) {
            
            [mVideoCamera.inputCamera lockForConfiguration:nil];
            [mVideoCamera.inputCamera setTorchMode:AVCaptureTorchModeAuto];
            [mVideoCamera.inputCamera setTorchModeOnWithLevel:0.1 error:nil];
            [mVideoCamera performSelector:@selector(takePhoto) withObject:nil afterDelay:0.1];
            [mVideoCamera.inputCamera unlockForConfiguration];
            
        } else {
            [mVideoCamera takePhoto];
        }
    }
}

- (IBAction)doneButtonClicked:(id)sender
{

}

- (IBAction)backButtonPressed:(id)sender {
    
    if (self.mVideoCamera.isRecordingMovie == YES) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^() {
        // do nothing
    }];
}

- (void)toggleFiltersButtonPressed:(id)sender {
            
    if (isFiltersTableViewVisible == YES) {
        
        self.isFiltersTableViewVisible = NO;
        
        CGRect tempRect = self.filterTableViewContainerView.frame;
        tempRect.origin.y = tempRect.origin.y + kFilterCellHeight;
        
        CGRect tempRectForCPUImageView = mVideoCamera.cpuImageView.frame;
        tempRectForCPUImageView.origin.y = tempRectForCPUImageView.origin.y + kCPUImageViewAnimationOffset;
        
        [UIView animateWithDuration:kFilterTableViewAnimationTime animations:^(){
            self.filterTableViewContainerView.frame = tempRect;
            self.mVideoCamera.cpuImageView.frame = tempRectForCPUImageView;
        }completion:^(BOOL finished) {
            
        }];
        
        
    } else {
        
        self.isFiltersTableViewVisible = YES;
        
        CGRect tempRect = self.filterTableViewContainerView.frame;
        tempRect.origin.y = tempRect.origin.y - kFilterCellHeight;
        
        CGRect tempRectForCPUImageView = mVideoCamera.cpuImageView.frame;
        tempRectForCPUImageView.origin.y = tempRectForCPUImageView.origin.y - kCPUImageViewAnimationOffset;
        
        [UIView animateWithDuration:kFilterTableViewAnimationTime animations:^(){
            
            self.filterTableViewContainerView.frame = tempRect;
            self.mVideoCamera.cpuImageView.frame = tempRectForCPUImageView;
            
        } completion:^(BOOL finished) {
            
        }];
        
        
    }
}


-(IBAction) handlePan:(UIGestureRecognizer *) sender {
    
    if (hasBlur) {
        
        CGPoint tapPoint = [sender locationInView:mImageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
        (GPUImageGaussianSelectiveBlurFilter*)mBlurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            [gpu setBlurSize:0.0f];
            if (isStatic) {
                [mStaticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            [gpu setBlurSize:0.0f];
            [self.blurOverlayView setCircleCenter:tapPoint];
            [gpu setExcludeCirclePoint:CGPointMake(tapPoint.x/320.0f, tapPoint.y/320.0f)];
        }
        
        if([sender state] == UIGestureRecognizerStateEnded){
            [gpu setBlurSize:2.0f];
            [self showBlurOverlay:NO];
            if (isStatic) {
                [mStaticPicture processImage];
            }
        }
    }
}


- (IBAction) handleTapToFocus:(UITapGestureRecognizer *)tgr{

    if (!isStatic && tgr.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tgr locationInView:mImageView];
        AVCaptureDevice *device = mVideoCamera.inputCamera;
        CGPoint pointOfInterest = CGPointMake(.5f, .5f);
        CGSize frameSize = [mImageView frame].size;
        
        if ([mVideoCamera isFrontFacingCameraPresent] == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
        }
        
        pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                [device setFocusPointOfInterest:pointOfInterest];
                
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                
                focusView.center = [tgr locationInView:self.view];
                focusView.alpha = 1;
                
                [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
                    focusView.alpha = 0;
                } completion:nil];
                
                [device unlockForConfiguration];
            } else {
                NSLog(@"ERROR = %@", error);
            }
        }
    }

}
 

-(IBAction) handlePinch:(UIPinchGestureRecognizer *) sender {
    
    if (hasBlur) {
        
        CGPoint midpoint = [sender locationInView:mImageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
        (GPUImageGaussianSelectiveBlurFilter*)mBlurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            [gpu setBlurSize:0.0f];
            if (isStatic) {
                [mStaticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            [gpu setBlurSize:0.0f];
            [gpu setExcludeCirclePoint:CGPointMake(midpoint.x/320.0f, midpoint.y/320.0f)];
            self.blurOverlayView.circleCenter = CGPointMake(midpoint.x, midpoint.y);
            CGFloat radius = MAX(MIN(sender.scale*[gpu excludeCircleRadius], 0.6f), 0.15f);
            self.blurOverlayView.radius = radius*320.f;
            [gpu setExcludeCircleRadius:radius];
            sender.scale = 1.0f;
        }
        
        if ([sender state] == UIGestureRecognizerStateEnded) {
            [gpu setBlurSize:2.0f];
            [self showBlurOverlay:NO];
            if (isStatic) {
                [mStaticPicture processImage];
            }
        }
    }
}


#pragma mark - View Will/Did Appear/Disappear

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.mVideoCamera isRecordingMovie] == YES) {
        [self.mVideoCamera stopRecordingMovie];
    }
    
    [self.mVideoCamera stopCameraCapture];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end
