//
//  SharedData.h
//  GiftMe
//
//  Created by Wang Yu Ping on 5/17/13.
//  Copyright (c) 2013 Interlogy, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialPhotoOperation.h"
#import "UserInfo.h"

@interface SharedData : NSObject
{
    
}

@property (nonatomic, retain) NSOperationQueue      *mOperationQueue;
@property (nonatomic, retain) SocialPhotoOperation  *mSocialPhotoOperation;
@property (nonatomic, retain) UserInfo              *mUserInfo;

+ (SharedData *) sharedData;
- (void) initSharedData;
+ (void) setUserLogined : (BOOL) login;
+ (BOOL) isUserLogined;
- (void) loadUserInfo;
- (void) saveUserInfo;
+ (void) showAlertView : (NSString *) message;
+(UIBarButtonItem*)customBarButtonItemWithText:(NSString*)buttonText;

@end
