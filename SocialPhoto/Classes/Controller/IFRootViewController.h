//
//  IFRootViewController.h
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDUploadProgressView.h"

@interface IFRootViewController : UIViewController<WDUploadProgressDelegate>
{
    IBOutlet UITableView        *mTableView;
    
    NSMutableArray              *mPostObjectList;
}

- (IBAction)startButtonPressed:(id)sender;

@end
