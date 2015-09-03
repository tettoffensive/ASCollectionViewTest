//
//  BaseViewController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "POLYViewController.h"

@interface BaseViewController : POLYViewController
- (void)loadViewControllerInForeground:(UIViewController *)viewController;
- (void)unloadViewController;
@end
