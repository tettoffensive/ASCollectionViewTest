//
//  ListChannelsViewController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseViewController.h"
#import "ChannelListerViewModel.h"

@interface ListChannelsViewController : BaseViewController
@property (nonatomic, strong) ChannelListerViewModel *viewModel; // covariant return type: https://en.wikipedia.org/wiki/Covariant_return_type
@end
