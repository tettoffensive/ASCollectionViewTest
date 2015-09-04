//
//  ChannelsNetworking.m
//  Channels
//
//  Created by Ryan Nelwan on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsNetworking.h"

@import AFNetworking;

@interface ChannelsNetworking()
@property (nonatomic, strong) AFHTTPSessionManager *api;
@end

@implementation ChannelsNetworking

+ (instancetype)sharedInstance
{
    static ChannelsNetworking *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
//        NSURL *url = [NSURL URLWithString:@"http://stage.channels.joinswipe.com/v1/"];
        NSURL *url = [NSURL URLWithString:@"http://channels.joinswipe.dev/v1/"];
        self.api = [[AFHTTPSessionManager alloc] initWithBaseURL: url];
    }
    return self;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Channel Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)fetchAllChannelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"channels" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *mutableArray = [NSMutableArray new];
        NSArray *list = [responseObject objectForKey:@"data"];
        for (NSDictionary *data in list) {
            ChannelModel *model = [ChannelModel modelWithDictionary:data];
            [mutableArray addObject:model];
        }
        
        if (success) {
            success([mutableArray copy]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)fetchAllPostsForChannelID:(NSInteger)channelID withSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"posts" parameters:@{@"channel_id":@(channelID)} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *mutableArray = [NSMutableArray new];
        NSArray *list = [responseObject objectForKey:@"data"];
        for (NSDictionary *data in list) {
            PostModel *model = [PostModel modelWithDictionary:data];
            [mutableArray addObject:model];
        }
        
        if (success) {
            success([mutableArray copy]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Post Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)createPostForChannelID:(NSInteger)channelID withMediaKey:(NSString *)mediaKey success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"post/create" parameters:@{@"channel_id":@(channelID),@"media_key":mediaKey} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - User Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)userRegisterWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"user/register" parameters:@{@"username":username,@"password":password,@"email":email} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)userLoginWithUsername:(NSString *)username andPassword:(NSString *)password success:(void(^)(NSDictionary *responseData))success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"user/login" parameters:@{@"username":username,@"password":password} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *data = [responseObject objectForKey:@"data"];
        if (success) success(data);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)userInfoWithUserModel:(UserModel *)userModel Success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"user/info" parameters:@{@"access_token":[[UserModel currentUser] accessToken]} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *data = [responseObject objectForKey:@"data"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

@end
