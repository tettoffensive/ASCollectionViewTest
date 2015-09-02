//
//  ChannelPlayerViewModel.m
//  Channels
//
//  Created by Stuart Tett on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelPlayerViewModel.h"

@implementation ChannelPlayerViewModel

- (NSArray *)channelPosts
{
    return @[@"http://channels-stage.videos.output.oregon.s3.amazonaws.com/7BE9A1E0-A430-45D1-8CC2-2D83253AEC69.m3u8",
             @"http://channels-stage.videos.output.oregon.s3.amazonaws.com/410A2517-FC16-42C5-8DD2-A5CCE2BD393E.m3u8"];
}

- (void)updateChannelTitle
{
    NSString *randomChannelString = [[[NSUUID UUID] UUIDString] substringToIndex:3];
    [self willChangeValueForKey:@"channelTitle"];
    _channelTitle = [@"Channel " stringByAppendingString:randomChannelString];
    [self didChangeValueForKey:@"channelTitle"];
}

- (NSArray *)keys
{
    return @[@"channelTitle"];
}

@end
