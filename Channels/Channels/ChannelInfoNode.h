//
//  ChannelInfoNode.h
//  Channels
//
//  Created by Stuart Tett on 9/11/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@class ChannelInfo;

@interface ChannelInfoNode : ASCellNode
- (instancetype)initWithInfo:(ChannelInfo*)info;
@end
