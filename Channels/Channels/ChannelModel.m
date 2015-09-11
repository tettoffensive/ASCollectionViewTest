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
    return @{
             @"channelID"          : @"id",
             @"title"              : @"title",
             @"updatedAt"          : @"updated_at",
             @"thumbnailURLString" : @"thumbnail_url",
             };
}

- (void)setChannelID:(NSString *)channelID
{
    _channelID = channelID;
}

+ (NSValueTransformer*)updatedAtJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
        return date;
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError *__autoreleasing *error) {
        return @([value timeIntervalSince1970]);
    }];
}


#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Network Calls
#pragma ------------------------------------------------------------------------------------------------------

// Fetches all public channels

+ (void)fetchChannelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure
{
    [[ChannelsNetworking sharedInstance] fetchAllChannelsWithSuccess:^(NSArray<ChannelModel *> *channels) {
        if (success) success(channels);
    } andFailure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)fetchPostsWithSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure
{
    [[ChannelsNetworking sharedInstance] fetchAllPostsForChannelID:self.channelID withSuccess:^(NSArray<PostModel *> *posts) {
        if (success) success(posts);
    } andFailure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

@end
