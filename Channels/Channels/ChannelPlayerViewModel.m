//
//  ChannelPlayerViewModel.m
//  Channels
//
//  Created by Stuart Tett on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelPlayerViewModel.h"

@implementation ChannelPlayerViewModel

- (void)updateChannelTitle
{
    NSString *randomChannelString = [[[NSUUID UUID] UUIDString] substringToIndex:3];
    [self willChangeValueForKey:@"channelTitle"];
    _channelTitle = [@"Channel " stringByAppendingString:randomChannelString];
    [self didChangeValueForKey:@"channelTitle"];
}

@end
