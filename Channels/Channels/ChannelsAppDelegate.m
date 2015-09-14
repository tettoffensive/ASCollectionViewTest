//
//  ChannelsAppDelegate.m
//  Channels
//
//  Created by Stuart Tett on 8/27/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsAppDelegate.h"

#import "ChannelsNavigationBar.h"
#import "ChannelViewController.h"
#import "LoginViewController.h"
#import "ListChannelsViewController.h"

#import "POLYUtils.h"
#import "POLYViewModel.h"
#import "POLYNetworking.h"
#import "POLYNetworking.h"

#import "ChannelPlayerViewModel.h"
#import "UserModel.h"

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
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    if (![UserModel isLoggedIn]) {
        [self loadLoginView];
    } else {
        [self loadListChannelView];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)loadLoginView
{
    LoginViewController *loginViewController = [LoginViewController new];
    _navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[ChannelsNavigationBar class] toolbarClass:nil];
    [_navigationController setViewControllers:@[loginViewController]];
    
    self.window.rootViewController = _navigationController;
}

- (void)loadListChannelView
{
    ChannelListerViewModel *viewModel = [ChannelListerViewModel new];
    [viewModel updateList];
    ListChannelsViewController *listChannelsViewController = [[ListChannelsViewController alloc] initWithViewModel:viewModel];
    _navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[ChannelsNavigationBar class] toolbarClass:nil];
    [_navigationController setViewControllers:@[listChannelsViewController]];
    
    self.window.rootViewController = _navigationController;
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