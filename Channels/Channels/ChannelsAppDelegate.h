//
//  ChannelsAppDelegate.h
//  Channels
//
//  Created by Stuart Tett on 8/27/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

@import UIKit;

@interface ChannelsAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (nonatomic) NSMutableArray *windows;
@property (strong, nonatomic) UIWindow *foregroundWindow;

- (void)loadLoginView;
- (void)loadChannelView;

@end

