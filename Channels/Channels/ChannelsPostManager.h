//
//  ChannelsPostManager.h
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelsPostManager : NSObject

+ (ChannelsPostManager *)sharedInstance;
- (void)postVideoData:(NSData *)videoData toChannel:(NSString *)channelID;

@end
