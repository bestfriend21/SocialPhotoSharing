//
//  MainViewController.m
//  SocialPhoto
//
//  Created by Wang YuPing on 8/22/13.
//  Copyright (c) 2013 twitter:@diwup. All rights reserved.
//

#import "MainViewController.h"
#import "IFAppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    mRegisterButtonLabel.font = [UIFont fontWithName:@"Rockwell Light.ttf" size:17.0];
    mLoginButtonLabel.font = [UIFont fontWithName:@"Rockwell Light.ttf" size:17.0];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) registerButtonClicked : (id) sender
{

}

- (IBAction) loginButtonClicked : (id) sender
{

}

@end
