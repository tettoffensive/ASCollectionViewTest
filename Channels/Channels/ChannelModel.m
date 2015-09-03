//
//  ChannelModel.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ChannelModel.h"
#import "PostModel.h"
#import "ChannelsNetworking.h"

@implementation ChannelModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"channelID": @"id", @"title": @"title"};
}

- (void)setChannelID:(NSInteger)channelID
{
    _channelID = channelID;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Network Calls
#pragma ------------------------------------------------------------------------------------------------------

// Fetches all public channels

+ (void)fetchChannelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure
{
    [[ChannelsNetworking sharedInstance] channelsWithSuccess:^(NSArray<ChannelModel *> *channels) {
        if (success) success(channels);
    } andFailure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)fetchPostsWithSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure
{
    [[ChannelsNetworking sharedInstance] postsForChannelID:self.channelID withSuccess:^(NSArray<PostModel *> *posts) {
        if (success) success(posts);
    } andFailure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

@end
