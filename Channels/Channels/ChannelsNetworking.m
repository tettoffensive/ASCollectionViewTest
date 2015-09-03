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
        NSURL *url = [NSURL URLWithString:@"http://stage.channels.joinswipe.com/v1/"];
        //NSURL *url = [NSURL URLWithString:@"http://channels.joinswipe.dev/v1/"];
        self.api = [[AFHTTPSessionManager alloc] initWithBaseURL: url];
    }
    return self;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Network Calls
#pragma ------------------------------------------------------------------------------------------------------

- (void)channelsWithSuccess:(void(^)(NSArray<ChannelModel *> *channels))success andFailure:(void(^)(NSError *error))failure
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

- (void)postsForChannelID:(NSInteger)channelID withSuccess:(void(^)(NSArray<PostModel *> *posts))success andFailure:(void(^)(NSError *error))failure
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

- (void)createPostForChannelID:(NSInteger)channelID withMediaKey:(NSString *)mediaKey success:(void(^)())success andFailure:(void(^)(NSError *error))failure
{
    [self.api POST:@"post/create" parameters:@{@"channelid":@(channelID),@"media_key":mediaKey} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

@end
