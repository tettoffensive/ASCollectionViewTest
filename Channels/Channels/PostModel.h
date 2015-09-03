//
//  VideoModel.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

/*
 General Notes: Video uploads will need to be uploaded into the "channels-stage.videos.input.oregon" bucket. We'll need to change "stage" to "production" when
 we release the app.
*/

#import "BaseModel.h"

@interface PostModel : BaseModel

@property (readonly)                    NSInteger postID;
@property (readonly)                    NSInteger channelID;
@property (readonly)                    NSInteger userID;
@property (nonatomic, copy, readonly)   NSString *mediaKey; // Must be in a UUID format.
@property (nonatomic, copy, readonly)   NSString *mediaURLString;
@property (nonatomic, copy, readonly)   NSString *mediaThumbnailURLString;
@property (readonly)                    BOOL mediaEncoded;

@property (nonatomic, copy, readonly)   NSURL *URL;
@property (nonatomic, copy, readonly)   NSURL *thumbnailURL;

- (void)createPostWithSuccess:(void(^)())success andFailure:(void(^)(NSError *error))failure;
- (void)setChannelID:(NSInteger)channelID;

@end
