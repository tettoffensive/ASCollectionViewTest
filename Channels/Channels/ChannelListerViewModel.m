//
//  ChannelListerViewModel.m
//  Channels
//
//  Created by Stuart Tett on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelListerViewModel.h"
#import "ChannelsNetworking.h"

@import DateTools.NSDate_DateTools;

NSString *const defaultName = @"My Feed";

@implementation ChannelListerViewModel

- (instancetype)init
{
    if (self = [super init]) {
        _listTitle = defaultName;
    }
    return self;
}


- (void)updateListWithError:(NSError *)error
{
    if (error.code == NSURLErrorNotConnectedToInternet) {
        // if we've already got the channel name just leave it
        [self updateListTitleWithString:@"No Offline Videos"];
    } else {
        [self updateListTitleWithString:[NSString stringWithFormat:@"Couldn't Refresh %@",self.listTitle]];
    }
}

- (void)updateListTitleWithString:(NSString *)title
{
    [self willChangeValueForKey:@"channelTitle"]; // willChange/didChange for KVO when changing ivars (since these are readonly properties)
    _listTitle = title;
    [self didChangeValueForKey:@"channelTitle"];
}

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
    NSParameterAssert([backingObject isKindOfClass:[ChannelModel class]]);
    return [super initWithBackingObject:backingObject];
}

- (NSString *)title
{
    return [self.backingObject title];
}

- (NSURL *)thumbnailURL
{
    return [NSURL URLWithString:[self.backingObject thumbnailURLString]];
}

- (BOOL)isTrending
{
    return FALSE;
}

- (NSString*)lastUpdatedString
{
    NSString *string = [[self.backingObject updatedAt] timeAgoSinceNow];
    if ([string length] > 0) {
        return string;
    }
    return @"";
}

- (BOOL)newPosts
{
    return FALSE;
}

@end
