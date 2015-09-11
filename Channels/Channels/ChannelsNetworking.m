//
//  ChannelsNetworking.m
//  Channels
//
//  Created by Ryan Nelwan on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsNetworking.h"
#import "ChannelsAppDelegate.h"

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
    }
    return self;
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    if ([UserModel isLoggedIn]) {
        NSString *accessToken = [[UserModel currentUser] accessToken];
        [self.manager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    }
    
    return [self.manager GET:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self handleStatusCode:[operation.response statusCode]];
        if (failure) failure(operation, error);
        
    }];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if ([UserModel isLoggedIn]) {
        NSString *accessToken = [[UserModel currentUser] accessToken];
        [self.manager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    }
    
    return [self.manager POST:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self handleStatusCode:[operation.response statusCode]];
        if (failure) failure(operation, error);
        
    }];
}

- (void)handleStatusCode:(NSInteger)statusCode
{
    switch (statusCode) {
        case 401:
            [[UserModel currentUser] logout];
            [(ChannelsAppDelegate *)[[UIApplication sharedApplication] delegate] loadLoginView];
            break;
            
        default:
            break;
    }
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Channel Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)fetchAllChannelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure
{
    [self GET:@"channels" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *mutableArray = [NSMutableArray new];
        NSArray *list = [responseObject objectForKey:@"data"];
        for (NSDictionary *data in list) {
            ChannelModel *model = [ChannelModel modelWithDictionary:data];
            [mutableArray addObject:model];
        }
        
        if (success) success([mutableArray copy]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)fetchAllPostsForChannelID:(NSString *)channelID withSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure
{
    [self GET:@"posts" parameters:@{@"channel_id":channelID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *mutableArray = [NSMutableArray new];
        NSArray *list = [responseObject objectForKey:@"data"];
        for (NSDictionary *data in list) {
            PostModel *model = [PostModel modelWithDictionary:data];
            [mutableArray addObject:model];
        }
        
        if (success) success([mutableArray copy]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Post Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)createPostForChannelID:(NSString *)channelID withMediaKey:(NSString *)mediaKey success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self POST:@"posts/create" parameters:@{@"channel_id":channelID,@"media_key":mediaKey} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)sendVoteResultsForPostID:(NSString *)postID withNumberOfVotesUp:(NSInteger)numberOfVotesUp andNumberOfVotesDown:(NSInteger)numberOfVotesDown success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    NSDictionary *data = @{@"post_id":postID,
                           @"upvotes": @(numberOfVotesUp),
                           @"downvotes":@(numberOfVotesDown)};
    
    [self POST:@"votes" parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - User Model
#pragma ------------------------------------------------------------------------------------------------------

- (void)userRegisterWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self POST:@"user/register" parameters:@{@"username":username,@"password":password,@"email":email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)userLoginWithUsername:(NSString *)username andPassword:(NSString *)password success:(void(^)(NSDictionary *responseData))success andFailure:(void(^)(NSError *error))failure
{
    [self POST:@"user/login" parameters:@{@"username":username,@"password":password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *data = [responseObject objectForKey:@"data"];
        if (success) success(data);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)userInfoWithUserModel:(UserModel *)userModel Success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    //[self.api POST:@"user/info" parameters:@{@"access_token":[[UserModel currentUser] accessToken]} success:^(NSURLSessionDataTask *task, id responseObject) {
    //    
    //    // NSDictionary *data = [responseObject objectForKey:@"data"];
    //    
    //} failure:^(NSURLSessionDataTask *task, NSError *error) {
    //    
    //    if (failure) failure(error);
    //    
    //}];
}

@end
