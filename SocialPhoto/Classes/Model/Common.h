//
//  Common.h
//  SocialPhoto
//
//  Created by Administrator on 8/22/13.
//  Copyright (c) 2013 twitter:@diwup. All rights reserved.
//

#ifndef SocialPhoto_Common_h
#define SocialPhoto_Common_h

#define BASEAPI_URL             @"http://192.168.0.63/socialphoto/%@"
#define SOCIALAPI               @"socialphotoapi.php"

#define kNotificationLoginFinish            @"kNotificationLoginFinish"
#define kNotificationLoginFail              @"kNotificationLoginFail"
#define kNotificationRegisterFinish         @"kNotificationRegisterFinish"
#define kNotificationRegisterFail           @"kNotificationRegisterFail"
#define kNotificationCheckUserFinish        @"kNotificationCheckUserFinish"
#define kNotificationCheckUserFail          @"kNotificationCheckUserFail"
#define kNotificationLoadUserInfo           @"kNotificationLoadUserInfo"
#define kNotificationUpdateTwitterButton    @"kNotificationUpdateTwitterButton"
#define kNotificationUploadImage            @"kNotificationUploadImage"
#define kNotificationUploadImageFinish      @"kNotificationUploadImageFinish"
#define kNotificationUploadImageFail        @"kNotificationUploadImageFail"
#define kNotificationGetFeedFinish          @"kNotificationGetFeedFinish"
#define kNotificationGetFeedFail            @"kNotificationGetFeedFail"

#define Default_Compression_Ratio                   0.5

typedef enum {
    CapLeft          = 0,
    CapMiddle        = 1,
    CapRight         = 2,
    CapLeftAndRight  = 3
} CapLocation;

#define BUTTON_WIDTH 40.0
#define BUTTON_SEGMENT_WIDTH 40.0
#define CAP_WIDTH 0.0

#endif
