//
//  SharedData.m
//  GiftMe
//
//  Created by Wang Yu Ping on 5/17/13.
//  Copyright (c) 2013 xinliang. All rights reserved.
//

#import "SharedData.h"
#import "Common.h"

static SharedData *g_sharedInfo = nil;

@implementation SharedData
@synthesize mOperationQueue;
@synthesize mSocialPhotoOperation;
@synthesize mUserInfo;

- (id) init {
	if ( self = [super init] ) {
		[self initSharedData];
	}
	return self;
}

+ (SharedData *) sharedData {
    
	if (g_sharedInfo == nil) {
		g_sharedInfo = [[SharedData alloc] init];
	}
    
	return g_sharedInfo;
}

- (void) initSharedData
{
    mOperationQueue = [[NSOperationQueue alloc] init];
    mSocialPhotoOperation = [[SocialPhotoOperation alloc] init];
    mUserInfo = [[UserInfo alloc] init];
    
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *userInfoPlistfile = [[NSBundle mainBundle] pathForResource:@"User" ofType:@"plist"];
    NSString *userInfoPath = [documentPath stringByAppendingPathComponent:@"User.plist"];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:userInfoPath] )
        [[NSFileManager defaultManager] copyItemAtPath:userInfoPlistfile toPath:userInfoPath error:nil];
    
    [self loadUserInfo];
}

+ (BOOL) isUserLogined
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"UserLogin"];
}

+ (void) setUserLogined : (BOOL) login
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:login forKey:@"UserLogin"];
    [defaults synchronize];
}

- (void) loadUserInfo
{
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistPath = [documentPath stringByAppendingPathComponent:@"User.plist"];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    mUserInfo.mUserId = [[dic objectForKey:@"userid"] integerValue];
    mUserInfo.mUsername = [dic objectForKey:@"username"];
    mUserInfo.mEmail = [dic objectForKey:@"email"];
    mUserInfo.mPassword = [dic objectForKey:@"password"];
    mUserInfo.mFullname = [dic objectForKey:@"fullname"];
    mUserInfo.mPhone = [dic objectForKey:@"phone"];
    mUserInfo.mPhotoUrl = [dic objectForKey:@"photourl"];
    mUserInfo.mCoverPhotoUrl = [dic objectForKey:@"coverphotourl"];
    mUserInfo.mLatitude = [[dic objectForKey:@"latitude"] doubleValue];
    mUserInfo.mLongitude = [[dic objectForKey:@"longitude"] doubleValue];
    mUserInfo.mLocation = [dic objectForKey:@"location"];
}

- (void) saveUserInfo
{
    //Initialize the informtion to feed the control
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *plistPath = [documentPath stringByAppendingPathComponent:@"User.plist"];
    
    // Build the array from the plist
    NSMutableDictionary* userData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    if ( userData == nil )
        userData = [[NSMutableDictionary alloc] init];
    
    [userData setObject:[NSNumber numberWithInt:mUserInfo.mUserId] forKey:@"userid"];
    [userData setObject:mUserInfo.mUsername forKey:@"username"];
    [userData setObject:mUserInfo.mEmail forKey:@"email"];
    [userData setObject:mUserInfo.mPassword forKey:@"password"];
    
    if ( mUserInfo.mPhone == nil || [mUserInfo.mPhone isEqualToString:@""] )
        [userData setObject:@"" forKey:@"phone"];
    else
        [userData setObject:mUserInfo.mPhone forKey:@"phone"];
    
    [userData setObject:mUserInfo.mPassword forKey:@"password"];
    
    if ( mUserInfo.mPhotoUrl == nil)
        [userData setObject:@"" forKey:@"photourl"];
    else
        [userData setObject:mUserInfo.mPhotoUrl forKey:@"photourl"];
    
    if ( mUserInfo.mCoverPhotoUrl == nil || [mUserInfo.mCoverPhotoUrl isEqualToString:@""] )
        [userData setObject:@"" forKey:@"coverphotourl"];
    else
        [userData setObject:mUserInfo.mCoverPhotoUrl forKey:@"coverphotourl"];
    
    [userData setObject:[NSNumber numberWithDouble:mUserInfo.mLatitude] forKey:@"latitude"];
    [userData setObject:[NSNumber numberWithDouble:mUserInfo.mLongitude] forKey:@"longitude"];
    
    if ( mUserInfo.mLocation == nil || [mUserInfo.mLocation isEqualToString:@""] )
        [userData setObject:@"" forKey:@"location"];
    else
        [userData setObject:mUserInfo.mLocation forKey:@"location"];
    
    [userData writeToFile:plistPath atomically:NO];

}

+ (void) showAlertView : (NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Social Photo" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

+(UIBarButtonItem*)customBarButtonItemWithText:(NSString*)buttonText
{
    return [[UIBarButtonItem alloc] initWithCustomView:[self customButtonWithText:buttonText stretch:CapLeftAndRight]];
}


+(UIImage*)image:(UIImage*)image withCap:(CapLocation)location capWidth:(NSUInteger)capWidth buttonWidth:(NSUInteger)buttonWidth
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(buttonWidth, image.size.height), NO, 0.0);
    
    if (location == CapLeft)
        // To draw the left cap and not the right, we start at 0, and increase the width of the image by the cap width to push the right cap out of view
        [image drawInRect:CGRectMake(0, 0, buttonWidth + capWidth, image.size.height)];
    else if (location == CapRight)
        // To draw the right cap and not the left, we start at negative the cap width and increase the width of the image by the cap width to push the left cap out of view
        [image drawInRect:CGRectMake(0.0-capWidth, 0, buttonWidth + capWidth, image.size.height)];
    else if (location == CapMiddle)
        // To draw neither cap, we start at negative the cap width and increase the width of the image by both cap widths to push out both caps out of view
        [image drawInRect:CGRectMake(0.0-capWidth, 0, buttonWidth + (capWidth * 2), image.size.height)];
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

+(UIButton*)customButtonWithText:(NSString*)buttonText stretch:(CapLocation)location
{
    UIImage* buttonImage = nil;
    UIImage* buttonPressedImage = nil;
    NSUInteger buttonWidth = 0;
    if (location == CapLeftAndRight)
    {
        buttonWidth = BUTTON_WIDTH;
        buttonImage = [[UIImage imageNamed:@"back_normal.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0];
        buttonPressedImage = [[UIImage imageNamed:@"back_pressed.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0];
    }
    else
    {
        buttonWidth = BUTTON_SEGMENT_WIDTH;
        
        buttonImage = [self image:[[UIImage imageNamed:@"back_normal.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0] withCap:location capWidth:CAP_WIDTH buttonWidth:buttonWidth];
        buttonPressedImage = [self image:[[UIImage imageNamed:@"back_pressed.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0] withCap:location capWidth:CAP_WIDTH buttonWidth:buttonWidth];
    }
    
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    
    [button setTitle:buttonText forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    
    return button;
}

@end
