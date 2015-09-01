//
//  ChannelViewController.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ChannelViewController.h"
#import "ChannelsInterface.h"

@implementation ChannelViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Channels";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setNavigationBarAppearance];
    self.view.backgroundColor = [ChannelsInterface viewBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBarAppearance
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self setNeedsStatusBarAppearanceUpdate]; // Ask the system to re-query our -preferredStatusBarStyle.
}

@end
