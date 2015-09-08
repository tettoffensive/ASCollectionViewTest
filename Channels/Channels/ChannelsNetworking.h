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

- (void)fetchAllChannelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure;
- (void)fetchAllPostsForChannelID:(NSInteger)channelID withSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure;
- (void)createPostForChannelID:(NSInteger)channelID withMediaKey:(NSString *)mediaKey success:(void(^)())success andFailure:(void(^)(NSError *error))failure;

// Please only call this from User model
- (void)userRegisterWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email success:(void(^)())success andFailure:(void(^)(NSError *error))failure;
- (void)userLoginWithUsername:(NSString *)username andPassword:(NSString *)password success:(void(^)(NSDictionary *responseData))success andFailure:(void(^)(NSError *error))failure;
- (void)userInfoWithUserModel:(UserModel *)userModel Success:(void(^)())success andFailure:(void(^)(NSError *error))failure;

@end
