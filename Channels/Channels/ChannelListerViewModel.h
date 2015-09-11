//
//  ChannelListerViewModel.h
//  Channels
//
//  Created by Stuart Tett on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "POLYViewModel.h"

@class ChannelInfo;

@interface ChannelListerViewModel : POLYViewModel
@property (nonatomic, copy, readonly) NSArray<ChannelInfo*> *channelList;

- (void)updateList;

@end

@interface ChannelInfo : ValueObject

@property (readonly) NSString      *title;
@property (readonly) NSURL         *thumbnailURL;
@property (readonly) BOOL           isTrending;
@property (readonly) NSTimeInterval lastChannelPostAt;
@property (readonly) BOOL           newPosts;

@end
