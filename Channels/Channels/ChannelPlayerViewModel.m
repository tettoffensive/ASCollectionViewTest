//
//  ChannelPlayerViewModel.m
//  Channels
//
//  Created by Stuart Tett on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelPlayerViewModel.h"
#import "ChannelsNetworking.h"
#import "ChannelListerViewModel.h"

NSString *const defaultChannelsName = @"";

@interface ChannelPlayerViewModel ()
{
    ChannelInfo *_currentChannel;
}

@end

@implementation ChannelPlayerViewModel

- (instancetype)init
{
    if (self = [super init]) {
        _channelTitle = defaultChannelsName;
    }
    return self;
}

- (void)updatePostsForCurrentChannel
{
    NSParameterAssert(_currentChannel);
    [self updatePostsForChannel:_currentChannel];
}

- (void)updatePostsForChannel:(ChannelInfo *)channel
{
    _currentChannel = channel;
    __weak __typeof(self)weakSelf = self;
    ChannelModel *channelModel = channel.backingObject;
    [self updateChannelTitleWithString:channelModel.title];
    if (channelModel) {
        [channelModel fetchPostsWithSuccess:^(NSArray<PostModel *> *posts) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf updateChannelPostsWithArray:[posts map:^id(PostModel *model) {
                return [[Post alloc] initWithBackingObject:model];
            }]];
        } andFailure:^(NSError *error) {
            POLYLog(@"Error : %@", error);
            [self updateChannelTitleWithError:error];
        }];
    }
}

- (void)updateChannelTitleWithError:(NSError *)error
{
    if (error.code == NSURLErrorNotConnectedToInternet) {
        // if we've already got the channel name just leave it
        [self updateChannelTitleWithString:@"No Offline Videos"];
    } else {
        [self updateChannelTitleWithString:[NSString stringWithFormat:@"Couldn't Refresh %@",self.channelTitle]];
    }
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
    if (_channelPosts && [_channelPosts count] > 0) {
        posts = [posts relativeComplement:_channelPosts];
        _channelPosts = [_channelPosts unionWithArray:posts];
    } else {
        _channelPosts = posts;
    }
    [self didChangeValueForKey:@"channelPosts"];
}

@end


@implementation Post

- (instancetype)initWithBackingObject:(id)backingObject
{
    NSParameterAssert([backingObject isKindOfClass:[PostModel class]]);
    return [super initWithBackingObject:backingObject];
}

- (NSURL *)URL
{
    return [NSURL URLWithString:[self.backingObject mediaURLString]];
}

- (NSURL *)thumbnailURL
{
    return [NSURL URLWithString:[self.backingObject mediaThumbnailURLString]];
}

- (NSString *)userName
{
    return @"anonymous";
}

- (void)voteUp
{
    [self.backingObject voteUp];
}

- (void)voteDown
{
    [self.backingObject voteDown];
}

- (void)sendVote
{
    [self.backingObject sendVoteWithSuccess:nil andFailure:nil];
}

@end
