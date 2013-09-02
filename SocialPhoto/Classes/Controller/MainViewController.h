//
//  MainViewController.h
//  SocialPhoto
//
//  Created by Wang YuPing on 8/22/13.
//  Copyright (c) 2013 twitter:@diwup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
{
    IBOutlet UIButton       *mRegisterButton;
    IBOutlet UIButton       *mLoginButton;
    
    IBOutlet UILabel        *mRegisterButtonLabel;
    IBOutlet UILabel        *mLoginButtonLabel;
}

- (IBAction) registerButtonClicked : (id) sender;
- (IBAction) loginButtonClicked : (id) sender;

@end
