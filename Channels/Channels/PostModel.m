//
//  VideoModel.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "PostModel.h"
#import "ChannelsNetworking.h"

@interface PostModel()

@end

@implementation PostModel

- (instancetype)initInChannel:(NSString *)channelID WithKey:(NSString *)key
{
    if (self = [super init]) {
        _channelID = channelID;
        _mediaKey = key;
    }
    return self;
}

+ (instancetype)newPostInChannel:(NSString *)channelID WithKey:(NSString *)key
{
    return [[PostModel alloc] initInChannel:channelID WithKey:key];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"postID": @"id",
             @"channelID": @"channel_id",
             @"userID":@"user_id",
             @"mediaKey":@"media_key",
             @"mediaEncoded":@"media_encoded",
             @"mediaURLString":@"media_url",
             @"mediaThumbnailURLString":@"media_thumbnail_url",
             @"votesUp":@"upvotes",
             @"votesDown":@"downvotes",
             };
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Current User Action
#pragma ------------------------------------------------------------------------------------------------------

- (void)voteUp
{
    POLYLog(@"UP");
    _currentUserNumberOfVotesUp++;
}

- (void)voteDown
{
    POLYLog(@"DOWN");
    _currentUserNumberOfVotesDown++;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Network Calls
#pragma ------------------------------------------------------------------------------------------------------

- (void)createPostWithSuccess:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [[ChannelsNetworking sharedInstance] createPostForChannelID:self.channelID withMediaKey:self.mediaKey success:^{
        if (success) success();
    } andFailure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)sendVoteWithSuccess:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    POLYLog(@"%ld %ld", self.currentUserNumberOfVotesUp,self.currentUserNumberOfVotesDown);
    return;
    [[ChannelsNetworking sharedInstance] sendVoteResultsForPostID:self.postID withNumberOfVotesUp:self.currentUserNumberOfVotesUp andNumberOfVotesDown:self.currentUserNumberOfVotesDown success:^{
        if (success) success();
    } andFailure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

@end
