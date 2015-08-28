//
//  VideoModel.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface VideoModel : MTLModel

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSURL *thumbnailURL;

@end
