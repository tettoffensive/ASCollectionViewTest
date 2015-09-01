//
//  ChannelsAppDelegate.m
//  Channels
//
//  Created by Stuart Tett on 8/27/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsAppDelegate.h"
#import "ChannelViewController.h"
#import "ChannelsNavigationBar.h"

@import POLYFoundation;

@interface ChannelsAppDelegate ()

@end

@implementation ChannelsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    ChannelViewController *channelViewController = [[ChannelViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[ChannelsNavigationBar class] toolbarClass:nil];
    [_navigationController setViewControllers:@[channelViewController]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];
    
    POLYNetworking *networking = [POLYNetworking sharedNetwork];
    NSLog(@"network %@",[networking description]);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end