//
//  VideoModel.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseModel.h"

@interface PostModel : BaseModel

@property (readonly)                    NSInteger postID;
@property (readonly)                    NSInteger channelID;
@property (readonly)                    NSInteger userID;
@property (readonly)                    NSInteger type;
@property (nonatomic, copy, readonly)   NSString *mediaKey;
@property (nonatomic, copy, readonly)   NSString *mediaURLString;
@property (nonatomic, copy, readonly)   NSString *mediaThumbnailURLString;
@property (readonly)                    BOOL mediaEncoded;

@property (nonatomic, copy, readonly)   NSURL *URL;
@property (nonatomic, copy, readonly)   NSURL *thumbnailURL;

@end
