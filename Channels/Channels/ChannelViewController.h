//
//  ChannelViewController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseViewController.h"
#import "ChannelPlayerViewModel.h"

@interface ChannelViewController : BaseViewController
@property (nonatomic, strong) ChannelPlayerViewModel *viewModel; // covariant return type: https://en.wikipedia.org/wiki/Covariant_return_type
@end
