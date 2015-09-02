//
//  ChannelPlayerViewModel.h
//  Channels
//
//  Created by Stuart Tett on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

@import POLYFoundation;

@interface ChannelPlayerViewModel : POLYViewModel

@property (nonatomic, copy, readonly) NSString *channelTitle;

- (void)updateChannelTitle;

@end
