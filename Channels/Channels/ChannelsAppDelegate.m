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
    
    //[application setStatusBarHidden:YES];
    
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
    
    self.windows = [NSMutableArray new];
    
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

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Loading up view controllers in the foreground (if you have a better solution, please feel free to make changes)
#pragma ------------------------------------------------------------------------------------------------------

- (void)loadForegroundWindowWithViewController:(UIViewController *)controller
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBarHidden = YES;
    [navigationController pushViewController:controller animated:NO];
    
    UIWindow *foregroundWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    foregroundWindow.backgroundColor = [UIColor clearColor];
    foregroundWindow.rootViewController = navigationController;
    foregroundWindow.windowLevel = UIWindowLevelStatusBar;
    foregroundWindow.hidden = NO;
    
    [self.windows addObject:foregroundWindow];
}

- (UIWindow *)foregroundWindow
{
    if ([self.windows count] == 0) {
        NSLog(@"WARNING - Windows count is zero.");
        return nil;
    }
    UIWindow *window = [self.windows objectAtIndex:[self.windows count] - 1];
    if (window == nil) return nil;
    return window;
}

- (void)unloadForegoundWindow
{
    UIWindow *window = [self.windows objectAtIndex:[self.windows count] - 1];
    NSMutableArray *newArray = [NSMutableArray new];
    
    for (UIWindow *w in self.windows) {
        if (w == window) {
            continue;
        }
        [newArray addObject:w];
    }
    
    [window setHidden:YES];
    window = nil;
    
    self.windows  = newArray;
}

- (void)unloadAllForegroundWindows
{
    for (UIWindow *w in self.windows) {
        [w setHidden:YES];
    }
    self.windows = [NSMutableArray new];
    return;
}

@end