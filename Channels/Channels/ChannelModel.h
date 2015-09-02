//
//  ChannelModel.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseModel.h"

@class PostModel;

@interface ChannelModel : BaseModel

@property (readonly) NSInteger channelID;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSArray<PostModel *> *channelPosts;

@end
