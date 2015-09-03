//
//  BaseViewController.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseViewController.h"
#import "ChannelsInterface.h"
#import "ChannelsAppDelegate.h"

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [ChannelsInterface viewBackgroundColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate]; // Ask the system to re-query our -preferredStatusBarStyle.
}

// Please use this sparingly

- (void)loadViewControllerInForeground:(UIViewController *)viewController
{
    ChannelsAppDelegate *appDelegate = (ChannelsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadForegroundWindowWithViewController:viewController];
}

- (void)unloadViewController
{
    ChannelsAppDelegate *appDelegate = (ChannelsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unloadForegoundWindow];
}

@end
