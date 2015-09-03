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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)uploadVideo:(NSDictionary *)videoDictionary
{
    //NSLog(@"Dict %@", videoDictionary);
    // PBJVisionVideoCapturedDurationKey
    // PBJVisionVideoPathKey
    // PBJVisionVideoThumbnailArrayKey
    // PBJVisionVideoThumbnailKey
    
    
    NSData *videoData = [NSData dataWithContentsOfFile:[videoDictionary objectForKey:@"PBJVisionVideoPathKey"]];
    
    [self.fileManager uploadVideoData:videoData
                             progress:^(CGFloat progress) {
                                 NSLog(@"Video Upload Progress: %.2f", progress);
                             } success:^(BOOL finished, NSString *key) {
                                 
                                 NSLog(@"Finished %@", finished == YES ? @"YES" : @"NO");
                                 NSLog(@"Success %@", key);
                                 
                                 // Fetch Channel
                                 [ChannelModel fetchChannelsWithSuccess:^(NSArray<ChannelModel *> *channels) {
                                     
                                     ChannelModel *channel = [channels objectAtIndex:0];
                                     NSInteger channelID = channel.channelID;
                                     
                                     // Call createPostWithSuccess
                                     PostModel *post = [PostModel new];
                                     [post setMediaKey:[[NSUUID UUID] UUIDString]];
                                     [post setChannelID:channelID];
                                     [post createPostWithSuccess:^{
                                         NSLog(@"Successfully Created Post");
                                     } andFailure:^(NSError *error) {
                                         NSLog(@"Failed to Create Post");
                                     }];
                                     
                                 } andFailure:^(NSError *error) {
                                     NSLog(@"Failed to fetch channel");
                                 }];
                                 

                             } failure:^(NSError *err) {
                                 NSLog(@"Failure %@", [err description]);
                             }];
}

@end