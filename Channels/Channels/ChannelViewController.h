//
//  ChannelViewController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

@import POLYFoundation;

@class ChannelPlayerViewModel;

@interface ChannelViewController : UIViewController
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithViewModel:(ChannelPlayerViewModel *)viewModel;

@property (nonatomic, strong) ChannelPlayerViewModel *viewModel;

@end
