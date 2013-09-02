//
//  IFRootViewController.m
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import "IFRootViewController.h"
#import "CameraViewController.h"
#import "CustomNavigationBar.h"
#import "WDUploadProgressView.h"
#import "DummyConnection.h"
#import "SharedData.h"
#import "Common.h"

#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

@implementation IFRootViewController

#pragma mark - Init

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
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initNotification];
//    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User Definition Method

- (void) initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUploadView:) name:kNotificationUploadImage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedFinish:) name:kNotificationGetFeedFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedFail:) name:kNotificationGetFeedFail object:nil];
}

- (void) uploadImageDidFinish : (NSNotification *) notification
{
    
}

#pragma mark - Buttons methods

- (IBAction) startButtonPressed : (id) sender {
    
    CameraViewController *filtersViewController;
    
    if ( [IFAppDelegate isFourInchScreen] == YES )
        filtersViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController~Four" bundle:nil];
    else
        filtersViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];        

    __block UINavigationController *navVc = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavigationBar class] toolbarClass:[UIToolbar class]];
    
    navVc.viewControllers = [NSArray arrayWithObject:filtersViewController];
    navVc.navigationBar.tintColor = [UIColor colorWithRed:210.0/255.0 green:80.0/255.0f blue:98.0f/255.0f alpha:1.0];
    // NavigationBar Background
    
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)navVc.navigationBar;
    
    [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"img_back_topbar.png"]];
    
    [navVc setNavigationBarHidden:YES];

    UIButton *aButton = (UIButton *)sender;
    
    switch (aButton.tag) {
        case 1: {
            filtersViewController.shouldLaunchAsAVideoRecorder = NO;
            filtersViewController.shouldLaunchAshighQualityVideo = NO;
            break;
        }
         
        case 2: {
            filtersViewController.shouldLaunchAsAVideoRecorder = YES;
            filtersViewController.shouldLaunchAshighQualityVideo = NO;
            break;
        }
        case 3: {
            filtersViewController.shouldLaunchAsAVideoRecorder = YES;
            filtersViewController.shouldLaunchAshighQualityVideo = YES;
            break;
        }
        default:
            break;
    }

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self presentViewController:navVc animated:YES completion:^(){
        navVc = nil;

    }];
    
}

@end
