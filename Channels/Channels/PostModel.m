//
//  VideoModel.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "PostModel.h"

@implementation PostModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"postID": @"id",
             @"channelID": @"channel_id",
             @"userID":@"user_id",
             @"type":@"type",
             @"mediaKey":@"media_key",
             @"mediaEncoded":@"media_encoded",
             @"mediaURLString":@"media_url",
             @"mediaThumbnailURLString":@"media_thumbnail_url",
             };
}

@end
