//
//  SocialPhotoOperation.m
//  SocialPhoto
//
//  Created by jin on 5/5/13.
//  Copyright (c) 2013 wang. All rights reserved.
//

#import "SocialPhotoOperation.h"
#import "SharedData.h"
#import "SBJsonParser.h"
#import "NSDate+MTDates.h"
#import "PostObject.h"
#import "Common.h"

@implementation SocialPhotoOperation

#pragma mark - ASIHttpRequest


- (void) requestUserLogin : (NSString *) username password : (NSString *) password
{    
    SharedData *sharedData = [SharedData sharedData];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:BASEAPI_URL, SOCIALAPI]]];

    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:60];
    [request addPostValue:@"login" forKey:@"task"];
    [request addPostValue:username forKey:@"username"];
    [request addPostValue:password forKey:@"passwd"];
	[request setDidFinishSelector:@selector(requestUserLoginFinish:)];
	[request setDidFailSelector:@selector(requestUserLoginFail:)];
    [request setDelegate:self];
    
    [sharedData.mOperationQueue addOperation:request];
}

- (void) requestUserRegister : (NSString *) username email : (NSString *) email password : (NSString *) password fullname : (NSString *) fullname photo : (NSData *) photo phone : (NSString *) phone
{
    SharedData *sharedData = [SharedData sharedData];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:BASEAPI_URL, SOCIALAPI]]];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:60];
    [request addPostValue:@"register" forKey:@"task"];
    [request addPostValue:username forKey:@"uname"];
    [request addPostValue:email forKey:@"email"];
    [request addPostValue:password forKey:@"pwd"];
    [request addPostValue:fullname forKey:@"fullname"];
    [request addData:photo forKey:@"photo"];

	[request setDidFinishSelector:@selector(requestUserRegisterFinish:)];
	[request setDidFailSelector:@selector(requestUserRegisterFail:)];
    [request setDelegate:self];
    
    [sharedData.mOperationQueue addOperation:request];
}

- (void) requestCheckuser : (NSString *) username
{
    SharedData *sharedData = [SharedData sharedData];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:BASEAPI_URL, SOCIALAPI]]];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:60];
    [request addPostValue:@"checkusername" forKey:@"task"];
    [request addPostValue:username forKey:@"username"];
    
	[request setDidFinishSelector:@selector(requestCheckUserFinish:)];
	[request setDidFailSelector:@selector(requestCheckUserFail:)];
    [request setDelegate:self];
    
    [sharedData.mOperationQueue addOperation:request];
}

- (void) requestPostPicture : (PostObject *) object
{
    SharedData *sharedData = [SharedData sharedData];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:BASEAPI_URL, SOCIALAPI]]];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:60];
    [request addPostValue:@"postpicture" forKey:@"task"];
    [request addPostValue:object.mTitle forKey:@"title"];
    [request addPostValue:object.mDescription forKey:@"desc"];
    
    NSString *categoryStr = @"";
    
    for ( NSString *key in [object.mCategoryDictionary allKeys] ) {
        
        NSInteger value = [[object.mCategoryDictionary objectForKey:key] integerValue];
        
        if ( value == 1 ) {
            categoryStr = [NSString stringWithFormat:@"%@,%@", categoryStr, key];
        }
        
    }
    
    if ( categoryStr.length > 0 )
        categoryStr = [categoryStr substringFromIndex:1];
    
    NSData *dataObj = UIImageJPEGRepresentation(object.mPhoto, 1.0);
    
    
    [request addPostValue:categoryStr forKey:@"cat"];
    [request addPostValue:[NSNumber numberWithInt:object.mPrivateFlag] forKey:@"pflag"];
    [request addPostValue:[NSNumber numberWithDouble:object.mLatitude] forKey:@"lat"];
    [request addPostValue:[NSNumber numberWithDouble:object.mLongitude] forKey:@"long"];
    [request addPostValue:object.mLocation forKey:@"loc"];
    [request addPostValue:[NSNumber numberWithInteger:object.mType] forKey:@"type"];
    [request addPostValue:[NSNumber numberWithInteger:object.mUserId] forKey:@"userid"];
    [request addData:dataObj forKey:@"photo"];
    
	[request setDidFinishSelector:@selector(requestPostPictureFinish:)];
	[request setDidFailSelector:@selector(requestPostPictureFail:)];
    [request setDelegate:self];
    
    [sharedData.mOperationQueue addOperation:request];
}

- (void) requestGetFeed
{
    SharedData *sharedData = [SharedData sharedData];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:BASEAPI_URL, SOCIALAPI]]];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:60];
    [request addPostValue:@"getfeed" forKey:@"task"];
    [request setDidFinishSelector:@selector(requestGetFeedFinish:)];
    [request setDidFailSelector:@selector(requestGetFeedFail:)];
    [request setDelegate:self];
    [sharedData.mOperationQueue addOperation:request];
}

#pragma mark - ASIHttpRequest Selector

- (void) requestGetFeedFinish : (ASIHTTPRequest *) request
{
    NSString *resStr = [request responseString];
    
    if ( resStr != nil ) {
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        id result = [jsonParser objectWithString:resStr];
        
        if ( result != nil ) {
            
            NSInteger status = [[result objectForKey:@"status"] integerValue];
            NSArray *postList = [result objectForKey:@"results"];
            
            if ( status == 1 && postList != nil ) {
                
                NSMutableArray *pictureList = [PostObject getPostObjectListFromArray:postList];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetFeedFinish object:pictureList];
                
                return;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetFeedFail object:nil];
}

- (void) requestGetFeedFail : (ASIHTTPRequest *) request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetFeedFail object:nil];
}

- (void) requestPostPictureFinish : (ASIHTTPRequest *) request
{
    NSString *resStr = [request responseString];
    
    if ( resStr != nil ) {
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        id result = [jsonParser objectWithString:resStr];
        
        if ( result != nil ) {
            
            NSInteger status = [[result objectForKey:@"status"] integerValue];

        }
        
    }
}

- (void) requestPostPictureFail : (ASIHTTPRequest *) request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCheckUserFail object:nil];
}

- (void) requestCheckUserFinish : (ASIHTTPRequest *) request
{
    NSString *resStr = [request responseString];
    
    if ( resStr != nil ) {
        
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        id result = [jsonParser objectWithString:resStr];
        
        if ( result != nil ) {
            
            NSInteger status = [[result objectForKey:@"status"] integerValue];
            id resultObject = [result objectForKey:@"results"];
            
            if ( status == 1 && resultObject != nil ) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCheckUserFinish object:resultObject];
                
                return;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCheckUserFail object:nil];
}

- (void) requestCheckUserFail : (ASIHTTPRequest *) request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCheckUserFail object:nil];    
}

- (void) requestUserLoginFinish : (ASIHTTPRequest *) request
{
    NSString *resStr = [request responseString];
    
    if ( resStr != nil ) {
        
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        id result = [jsonParser objectWithString:resStr];
        
        if ( result != nil ) {
            
            NSInteger status = [[result objectForKey:@"status"] integerValue];
            id resultObject = [result objectForKey:@"results"];
            
            if ( status == 1 && resultObject != nil ) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginFinish object:resultObject];
             
                return;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginFail object:nil];
}

- (void) requestUserLoginFail : (ASIHTTPRequest *) request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginFail object:nil];
}

- (void) requestUserRegisterFinish : (ASIHTTPRequest *) request
{
    NSString *resStr = [request responseString];
    
    if ( resStr != nil ) {
        
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        id data = [jsonParser objectWithString:resStr];
        
        if ( data != nil && [data count] > 0 ) {
            
            NSInteger status = [[data objectForKey:@"status"] integerValue];
            NSString *result = [data objectForKey:@"results"];

            if ( status == 1 ) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterFinish object:result];
                return;
                
            } else if ( status == 2 ) {
                                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterFinish object:nil];
                return;
            }

        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterFail object:nil];
}

- (void) requestUserRegisterFail : (ASIHTTPRequest *) request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterFail object:nil];
}

@end
