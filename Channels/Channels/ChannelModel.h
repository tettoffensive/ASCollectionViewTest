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

@property NSInteger channelID;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSArray<PostModel *> *channelPosts;

+ (void)fetchChannelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure;
- (void)fetchPostsWithSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure;

@end
