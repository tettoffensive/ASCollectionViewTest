//
//  ChannelsPostManager.m
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsPostManager.h"
#import "ChannelsConfig.h"
#import "POLYFoundation.h"

#import "PostModel.h"
#import "ChannelModel.h"

NSString *const ChannelsPostManagerDidStartUploadNotification           = @"ChannelsPostManagerDidStartUploadNotification";
NSString *const ChannelsPostManagerDidUpdateUploadProgressNotification  = @"ChannelsPostManagerDidUpdateUploadProgressNotification";
NSString *const ChannelsPostManagerDidCompleteUploadNotification        = @"ChannelsPostManagerDidCompleteUploadNotification";
NSString *const ChannelsPostManagerDidFailUploadNotification            = @"ChannelsPostManagerDidFailUploadNotification";

@interface ChannelsPostManager()

@property (nonatomic) POLYFileManager *fileManager;

@end

@implementation ChannelsPostManager

static ChannelsPostManager *sharedChannelsPostManagerInstance = nil;

+ (ChannelsPostManager *)sharedInstance
{
    if (!sharedChannelsPostManagerInstance) {
        sharedChannelsPostManagerInstance = [[ChannelsPostManager alloc] init];
    }
    return sharedChannelsPostManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _fileManager = [[POLYFileManager alloc] initWithAccessKey:CONFIG_AMAZON_S3_ACCESS_KEY
                                                        withSecretKey:CONFIG_AMAZON_S3_SECRET_KEY];
        [_fileManager setBucket:@"channels-stage.videos.input.oregon"];
//        [_fileManager setSubpath:@"test"];
    }
    return self;
}

- (void)postVideoData:(NSData *)videoData toChannel:(NSString *)channelID
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ChannelsPostManagerDidStartUploadNotification object:self];
    
    [self.fileManager uploadVideoData:videoData
                             progress:^(CGFloat progress) {
                                 NSLog(@"Video Upload Progress: %.2f", progress);
                                 NSDictionary *userInfo = @{@"VIDEO EXPORT PROGRESS" : [NSNumber numberWithFloat:progress]};
                                 [[NSNotificationCenter defaultCenter] postNotificationName:ChannelsPostManagerDidUpdateUploadProgressNotification object:userInfo];
                             } success:^(BOOL finished, NSString *key) {
                                 
                                 NSLog(@"Finished %@", finished == YES ? @"YES" : @"NO");
                                 NSLog(@"Success %@", key);
                                 
                                 PostModel *post = [PostModel newPostInChannel:channelID WithKey:key];
                                 [post createPostWithSuccess:^{
                                     NSLog(@"Successfully Created Post to Channel ID: %@", channelID);
                                     [[NSNotificationCenter defaultCenter] postNotificationName:ChannelsPostManagerDidCompleteUploadNotification object:self];
                                 } andFailure:^(NSError *error) {
                                     NSLog(@"Failed to Create Post");
                                     [[NSNotificationCenter defaultCenter] postNotificationName:ChannelsPostManagerDidFailUploadNotification object:self];
                                 }];
                                 
                             } failure:^(NSError *err) {
                                 NSLog(@"Failure %@", [err description]);
                             }];
}

@end