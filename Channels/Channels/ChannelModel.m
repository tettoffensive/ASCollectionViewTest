//
//  ChannelModel.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ChannelModel.h"

@implementation ChannelModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"channelID": @"id", @"title": @"title"};
}

@end
