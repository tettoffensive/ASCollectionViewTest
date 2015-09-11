//
//  ChannelInfoNode.h
//  Channels
//
//  Created by Stuart Tett on 9/11/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@class ChannelInfo;
@class ChannelInfoNode;

@protocol ChannelInfoNodeDelegate <NSObject>
@optional
- (void)channelNodeWasTapped:(ChannelInfo*)channel;
@end

@interface ChannelInfoNode : ASCellNode
@property (nonatomic, weak) id<ChannelInfoNodeDelegate> delegate;
- (instancetype)initWithInfo:(ChannelInfo*)info;
@end
