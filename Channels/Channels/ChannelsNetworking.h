//
//  ChannelsNetworking.h
//  Channels
//
//  Created by Ryan Nelwan on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "Models.h"

@interface ChannelsNetworking : NSObject

- (instancetype)init NS_UNAVAILABLE NS_DESIGNATED_INITIALIZER;
+ (instancetype)sharedInstance;

- (void)channelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure;
- (void)postsForChannelID:(NSInteger)channelID withSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure;

@end
