//
//  ChannelPlayerViewModel.h
//  Channels
//
//  Created by Stuart Tett on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "POLYViewModel.h"

@class Post;

@interface ChannelPlayerViewModel : POLYViewModel

@property (nonatomic, copy, readonly) NSString  *channelTitle;
@property (nonatomic, copy, readonly) NSArray<Post*> *channelPosts;

- (void)updatePosts;

@end

@interface Post : ValueObject

@property (readonly) NSURL *URL;
@property (readonly) NSURL *thumbnailURL;
@property (readonly) NSString *userName;

- (void)voteUp;
- (void)voteDown;
- (void)sendVote;

@end
