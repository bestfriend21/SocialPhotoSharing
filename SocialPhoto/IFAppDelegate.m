//
//  IFAppDelegate.m
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import "IFAppDelegate.h"
#import "IFRootViewController.h"
#import "MainViewController.h"
#import "SharedData.h"
#import "Common.h"
#import "CustomNavigationBar.h"

@implementation IFAppDelegate

@synthesize window = _window;
@synthesize session = _session;
@synthesize mRequestCall;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    
    if ( [SharedData isUserLogined] == YES ) {
        
        MainViewController *mainVc;
        
        if ( [IFAppDelegate isFourInchScreen] == YES )
            mainVc = [[MainViewController alloc] initWithNibName:@"MainViewController_Four" bundle:nil];
        else
            mainVc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        
        
        UINavigationController *searchNavigationVc = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavigationBar class] toolbarClass:[UIToolbar class]];
        
        searchNavigationVc.viewControllers = [NSArray arrayWithObject:mainVc];
        searchNavigationVc.navigationBar.tintColor = [UIColor colorWithRed:210.0/255.0 green:80.0/255.0f blue:98.0f/255.0f alpha:1.0];
        // NavigationBar Background
        
        CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)searchNavigationVc.navigationBar;
        
        [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"img_back_topbar.png"]];
                
        self.window.rootViewController = searchNavigationVc;
        
    } else {
    
        IFRootViewController *ifRootViewController = [[IFRootViewController alloc] init];
        self.window.rootViewController = ifRootViewController;

        UINavigationController *rootNavVc = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavigationBar class] toolbarClass:[UIToolbar class]];
        rootNavVc.navigationBar.tintColor = [UIColor colorWithRed:210.0/255.0 green:80.0/255.0f blue:98.0f/255.0f alpha:1.0];

        rootNavVc.viewControllers = [NSArray arrayWithObject:ifRootViewController];
        
        CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)rootNavVc.navigationBar;
        
        [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"img_back_topbar.png"]];
        
        self.window.rootViewController = rootNavVc;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
    
    if ( mRequestCall == YES ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadUserInfo object:nil];
        mRequestCall = NO;
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.session close];
}

+ (BOOL) isFourInchScreen
{
    IFAppDelegate *appDelegate = (IFAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ( appDelegate.window.bounds.size.height == 568 )
        return YES;
    
    return NO;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    self.mRequestCall = YES;
    
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}


@end
