//
//  PostObject.h
//  SocialPhoto
//
//  Created by Administrator on 8/24/13.
//  Copyright (c) 2013 twitter:@diwup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostObject : NSObject
{
    
}

@property (nonatomic, assign) NSInteger     mId;
@property (nonatomic, retain) NSString      *mTitle;
@property (nonatomic, retain) NSString      *mDescription;
@property (nonatomic, retain) NSString      *mLocation;
@property (nonatomic, assign) double        mLatitude;
@property (nonatomic, assign) double        mLongitude;
@property (nonatomic, assign) NSInteger     mPrivateFlag;
@property (nonatomic, assign) NSInteger     mType;
@property (nonatomic, assign) NSInteger     mUserId;
@property (nonatomic, assign) UIImage       *mPhoto;
@property (nonatomic, retain) NSMutableDictionary   *mCategoryDictionary;
@property (nonatomic, assign) NSInteger     mTimeStamp;
@property (nonatomic, retain) NSString      *mPhotoUrl;

+ (NSMutableArray *) getPostObjectListFromArray : (NSArray *) list;

@end
