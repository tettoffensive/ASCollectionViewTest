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
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
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
        //NSURL *url = [NSURL URLWithString:@"http://stage.channels.joinswipe.com/v1/"];
        //NSURL *url = [NSURL URLWithString:@"http://channels.joinswipe.dev/v1/"];
        //NSURL *url = [NSURL URLWithString:@"http://192.168.1.32/v1/"];
        
        NSURL *url = [NSURL URLWithString:@"http://channels-dev-1133499222.us-west-2.elb.amazonaws.com/"];
        
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        if ([UserModel isLoggedIn]) {
            NSString *accessToken = [[UserModel currentUser] accessToken];
            [self.manager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
        }
        
    }
    return self;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Channel Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)fetchAllChannelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure
{
    [self.manager GET:@"channels" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *mutableArray = [NSMutableArray new];
        NSArray *list = [responseObject objectForKey:@"data"];
        for (NSDictionary *data in list) {
            ChannelModel *model = [ChannelModel modelWithDictionary:data];
            [mutableArray addObject:model];
        }
        
        if (success) {
            success([mutableArray copy]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)fetchAllPostsForChannelID:(NSString *)channelID withSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure
{
    [self.manager GET:@"posts" parameters:@{@"channel_id":channelID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *mutableArray = [NSMutableArray new];
        NSArray *list = [responseObject objectForKey:@"data"];
        for (NSDictionary *data in list) {
            PostModel *model = [PostModel modelWithDictionary:data];
            [mutableArray addObject:model];
        }
        
        if (success) {
            success([mutableArray copy]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Post Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)createPostForChannelID:(NSString *)channelID withMediaKey:(NSString *)mediaKey success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self.manager POST:@"post/create" parameters:@{@"channel_id":channelID,@"media_key":mediaKey,@"user_id":[UserModel isLoggedIn] ? [[UserModel currentUser] userID] : 0} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

//- (void)requestMethod:(NSString *)requestMethod URLString:(NSString *)urlString parameters:

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - User Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)userRegisterWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self.manager POST:@"user/register" parameters:@{@"username":username,@"password":password,@"email":email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)userLoginWithUsername:(NSString *)username andPassword:(NSString *)password success:(void(^)(NSDictionary *responseData))success andFailure:(void(^)(NSError *error))failure
{
    [self.manager POST:@"user/login" parameters:@{@"username":username,@"password":password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *data = [responseObject objectForKey:@"data"];
        if (success) success(data);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)userInfoWithUserModel:(UserModel *)userModel Success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"user/info" parameters:@{@"access_token":[[UserModel currentUser] accessToken]} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // NSDictionary *data = [responseObject objectForKey:@"data"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

@end
