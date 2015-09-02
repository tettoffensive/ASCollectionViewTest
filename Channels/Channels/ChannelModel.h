//
//  ChannelModel.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import <Mantle/Mantle.h>
@class PostModel;

@interface ChannelModel : MTLModel

@property (nonatomic, copy, readonly) NSString *channelName;
@property (nonatomic, copy, readonly) NSArray<PostModel *> *channelPosts;

@end
