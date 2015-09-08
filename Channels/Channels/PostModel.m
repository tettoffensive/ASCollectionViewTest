//
//  VideoModel.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "PostModel.h"
#import "ChannelsNetworking.h"

@implementation PostModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"postID": @"id",
             @"channelID": @"channel_id",
             @"userID":@"user_id",
             @"mediaKey":@"media_key",
             @"mediaEncoded":@"media_encoded",
             @"mediaURLString":@"media_url",
             @"mediaThumbnailURLString":@"media_thumbnail_url",
             };
}

- (NSURL *)URL
{
    return [NSURL URLWithString:self.mediaURLString];
}

- (NSURL *)thumbnailURL
{
    return [NSURL URLWithString:self.mediaThumbnailURLString];
}

- (void)setChannelID:(NSInteger)channelID
{
    _channelID = channelID;
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

@end
