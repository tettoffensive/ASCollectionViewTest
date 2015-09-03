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
#import "ChannelPlayerViewModel.h"

#import "POLYUtils.h"
#import "POLYViewModel.h"
#import "POLYNetworking.h"
#import "POLYNetworking.h"

void uncaughtExceptionHandler(NSException *exception) {
    POLYLog(@"CRASH: %@", exception);
    POLYLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

@interface ChannelsAppDelegate ()

@end

@implementation ChannelsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [application setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    ChannelPlayerViewModel *viewModel = [[ChannelPlayerViewModel alloc] init];
    [viewModel updatePosts];
    
    ChannelViewController *channelViewController = [[ChannelViewController alloc] initWithViewModel:viewModel];
    _navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[ChannelsNavigationBar class] toolbarClass:nil];
    [_navigationController setViewControllers:@[channelViewController]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];
    
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