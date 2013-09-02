//
//  PostObject.m
//  SocialPhoto
//
//  Created by Administrator on 8/24/13.
//  Copyright (c) 2013 twitter:@diwup. All rights reserved.
//

#import "PostObject.h"

@implementation PostObject
@synthesize mId;
@synthesize mTitle;
@synthesize mDescription;
@synthesize mLocation;
@synthesize mLatitude;
@synthesize mLongitude;
@synthesize mPrivateFlag;
@synthesize mType;
@synthesize mUserId;
@synthesize mPhoto;
@synthesize mCategoryDictionary;
@synthesize mPhotoUrl;
@synthesize mTimeStamp;

+ (NSMutableArray *) getPostObjectListFromArray : (NSArray *) list
{
    NSMutableArray *postList = [[NSMutableArray alloc] init];
    
    for ( id object in list) {
        
        PostObject *postObject = [[PostObject alloc] init];
        postObject.mId = [[object objectForKey:@"id"] integerValue];
        postObject.mTitle = [object objectForKey:@"title"];
        postObject.mDescription = [object objectForKey:@"desc"];

        NSString *categoryStr = [object objectForKey:@"cat"];
        NSArray *catArray = [categoryStr componentsSeparatedByString:@","];
        
        postObject.mCategoryDictionary = [[NSMutableDictionary alloc] init];
        
        for ( NSString *key in catArray )
            [postObject.mCategoryDictionary setObject:[NSNumber numberWithInteger:1] forKey:key];
        
        postObject.mLocation = [object objectForKey:@"loc"];
        postObject.mLatitude = [[object objectForKey:@"lat"] doubleValue];
        postObject.mLongitude = [[object objectForKey:@"long"] doubleValue];
        postObject.mUserId = [[object objectForKey:@"uid"] integerValue];
        postObject.mPrivateFlag = [[object objectForKey:@"pflag"] integerValue];
        postObject.mType = [[object objectForKey:@"type"] integerValue];
        postObject.mTimeStamp = [[object objectForKey:@"regdate"] integerValue];
        postObject.mPhotoUrl = [object objectForKey:@"ppath"];
        
        [postList addObject:postObject];
    }
    
    return postList;
}

@end
