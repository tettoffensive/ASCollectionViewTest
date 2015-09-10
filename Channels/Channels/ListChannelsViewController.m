//
//  ListChannelsViewController.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ListChannelsViewController.h"

@implementation ListChannelsViewController

@dynamic viewModel; // required for covariant return type: https://en.wikipedia.org/wiki/Covariant_return_type

- (instancetype)initWithViewModel:(ChannelListerViewModel *)viewModel
{
    if (self = [super initWithViewModel:viewModel]) {
        
    }
    return self;
}

@end
