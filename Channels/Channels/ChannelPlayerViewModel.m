//
//  ChannelPlayerViewModel.m
//  Channels
//
//  Created by Stuart Tett on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelPlayerViewModel.h"
#import "ChannelsNetworking.h"

@implementation ChannelPlayerViewModel

- (void)updatePosts
{
    ChannelsNetworking *networking = [ChannelsNetworking sharedInstance];
    __weak __typeof(self)weakSelf = self;
    [networking channelsWithSuccess:^(NSArray<ChannelModel *> *channels) {
        ChannelModel *channelModel = channels[0];
        [self updateChannelTitleWithString:channelModel.title];
        if (channelModel) {
            [channelModel fetchPostsWithSuccess:^(NSArray<PostModel *> *posts) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf updateChannelPostsWithArray:[posts map:^id(PostModel *post) {
                    return post.mediaURLString;
                }]];
            } andFailure:^(NSError *error) {
                POLYLog(@"Error : %@", error);
            }];
        }
    } andFailure:^(NSError *error) {
        POLYLog(@"Fetch Channel Error : %@", error);
    }];
}

- (void)updateChannelTitleWithString:(NSString *)title
{
    [self willChangeValueForKey:@"channelTitle"]; // willChange/didChange for KVO when changing ivars (since these are readonly properties)
    _channelTitle = title;
    [self didChangeValueForKey:@"channelTitle"];
}

- (void)updateChannelPostsWithArray:(NSArray*)posts
{
    [self willChangeValueForKey:@"channelPosts"];
    _channelPosts = posts;
    [self didChangeValueForKey:@"channelPosts"];
}



- (NSArray *)keys
{
    return @[@"channelTitle",
             @"channelPosts"];
}

@end
