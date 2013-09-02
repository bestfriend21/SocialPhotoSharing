//
//  UserInfo.m
//  SocialPhoto
//
//  Created by Administrator on 8/22/13.
//  Copyright (c) 2013 twitter:@diwup. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize mUserId;
@synthesize mUsername;
@synthesize mPassword;
@synthesize mEmail;
@synthesize mFullname;
@synthesize mPhoto;
@synthesize mCoverPhoto;
@synthesize mPhone;
@synthesize mLocation;
@synthesize mLatitude;
@synthesize mLongitude;
@synthesize mPhotoData;

+ (UserInfo *) initUserInfoWithObject : (id) user
{
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo.mUserId = [[user objectForKey:@"id"] integerValue];
    userInfo.mUsername = [user objectForKey:@"uname"];
    userInfo.mEmail = [user objectForKey:@"email"];
    userInfo.mPassword = [user objectForKey:@"pwd"];
    userInfo.mFullname = [user objectForKey:@"fullname"];
    userInfo.mPhone = [user objectForKey:@"phone"];
    userInfo.mPhoto = [user objectForKey:@"photo"];
    userInfo.mCoverPhoto = [user objectForKey:@"cphoto"];
    userInfo.mLocation = [user objectForKey:@"loc"];
    userInfo.mLatitude = [[user objectForKey:@"latitude"] doubleValue];
    userInfo.mLongitude = [[user objectForKey:@"longitude"] doubleValue];
    
    return userInfo;
}

@end
