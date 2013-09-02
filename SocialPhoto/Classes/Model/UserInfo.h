//
//  UserInfo.h
//  SocialPhoto
//
//  Created by Administrator on 8/22/13.
//  Copyright (c) 2013 twitter:@diwup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, assign) NSInteger     mUserId;
@property (nonatomic, retain) NSString      *mUsername;
@property (nonatomic, retain) NSString      *mPassword;
@property (nonatomic, retain) NSString      *mEmail;
@property (nonatomic, retain) NSString      *mFullname;
@property (nonatomic, retain) NSString      *mPhoto;
@property (nonatomic, retain) NSString      *mCoverPhoto;
@property (nonatomic, retain) NSString      *mPhone;
@property (nonatomic, retain) NSString      *mLocation;
@property (nonatomic, assign) double         mLatitude;
@property (nonatomic, assign) double         mLongitude;
@property (nonatomic, retain) NSString      *mPhotoUrl;
@property (nonatomic, retain) NSString      *mCoverPhotoUrl;
@property (nonatomic, retain) NSData        *mPhotoData;

+ (UserInfo *) initUserInfoWithObject : (id) user;

@end
