//
//  ChannelModel.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import <Mantle/Mantle.h>
@class VideoModel;

@interface ChannelModel : MTLModel

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSArray<VideoModel *> *videos;

@end
