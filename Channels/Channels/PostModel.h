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

- (instancetype)initInChannel:(NSString *)channelID WithKey:(NSString *)key;
+ (instancetype)newPostInChannel:(NSString *)channelID WithKey:(NSString *)key;

@property (readonly)                    NSString *postID;
@property (readonly)                    NSString *channelID;
@property (readonly)                    NSString *userID;
@property (nonatomic, copy, readonly)   NSString *mediaKey; // Must be in a UUID format.
@property (nonatomic, copy, readonly)   NSString *mediaURLString;
@property (nonatomic, copy, readonly)   NSString *mediaThumbnailURLString;
@property (readonly)                    BOOL mediaEncoded;

- (void)voteUp;
- (void)voteDown;

- (void)createPostWithSuccess:(void(^)())success andFailure:(void(^)(NSError *error))failure;
- (void)sendVoteWithSuccess:(void(^)())success andFailure:(void(^)(NSError *error))failure;

@end
