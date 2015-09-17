//
//  AppDelegate.m
//
//  Created by Stuart Tett on 8/27/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "AppDelegate.h"
#import "ListViewController.h"

#import "ViewModel.h"

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    [self loadListView];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)loadListView
{
    ListerViewModel *viewModel = [ListerViewModel new];
    [viewModel updateList];
    ListViewController *listViewController = [[ListViewController alloc] initWithViewModel:viewModel];
    _navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:nil];
    [_navigationController setViewControllers:@[listViewController]];
    
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