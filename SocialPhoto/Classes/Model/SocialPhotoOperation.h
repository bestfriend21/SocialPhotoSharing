//
//  SocialPhotoOperation.h
//  SocialPhoto
//
//  Created by jin on 5/5/13.
//  Copyright (c) 2013 wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "PostObject.h"

@interface SocialPhotoOperation : NSObject<ASIHTTPRequestDelegate>
{
    
}

- (void) requestUserLogin : (NSString *) username password : (NSString *) password;
- (void) requestUserRegister : (NSString *) username email : (NSString *) email password : (NSString *) password fullname : (NSString *) fullname photo : (NSData *) photo phone : (NSString *) phone;
- (void) requestCheckuser : (NSString *) username;
- (void) requestPostPicture : (PostObject *) object;
- (void) requestGetFeed;



@end
