//
//  ChannelListerViewModel.m
//  Channels
//
//  Created by Stuart Tett on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelListerViewModel.h"
#import "ChannelsNetworking.h"

@implementation ChannelListerViewModel

- (void)updateList
{
    ChannelsNetworking *networking = [ChannelsNetworking sharedInstance];
    __weak __typeof(self)weakSelf = self;
    [networking fetchAllChannelsWithSuccess:^(NSArray<ChannelModel *> *channels) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf updateChannelListWithArray:[channels map:^id(ChannelModel *model) {
            return [[ChannelInfo alloc] initWithBackingObject:model];
        }]];
    } andFailure:^(NSError *error) {
        POLYLog(@"Fetch Channels Error : %@", error);
    }];
}

- (void)updateChannelListWithArray:(NSArray<ChannelInfo *>*)channels
{
    [self willChangeValueForKey:@"channelList"];
    if (_channelList && [_channelList count] > 0) {
        channels = [channels relativeComplement:_channelList];
        _channelList = [_channelList unionWithArray:channels];
    } else {
        _channelList = channels;
    }
    [self didChangeValueForKey:@"channelList"];
}

@end


@implementation ChannelInfo

- (instancetype)initWithBackingObject:(id)backingObject
{
    NSParameterAssert([backingObject isKindOfClass:[PostModel class]]);
    return [super initWithBackingObject:backingObject];
}

- (NSString *)title
{
    return [self.backingObject title];
}

- (NSURL *)thumbnailURL
{
    return [NSURL URLWithString:@"https://usatftw.files.wordpress.com/2013/07/xxx-d01-nickelback-16.jpg"];
//    return [NSURL URLWithString:[self.backingObject mediaThumbnailURLString]];
}

- (NSUInteger)numberOfChannelViews
{
    return 49000000;
}

- (BOOL)isTrending
{
    return FALSE;
}

- (NSTimeInterval)lastChannelPostAt
{
  return [[NSDate date] timeIntervalSince1970];
}

- (BOOL)newPosts
{
    return FALSE;
}

@end
