//
//  ChannelViewController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseViewController.h"
#import "ChannelPlayerViewModel.h"

@interface ChannelViewController : BaseViewController<UIGestureRecognizerDelegate>
@property (nonatomic, strong) ChannelPlayerViewModel *viewModel; // covariant return type: https://en.wikipedia.org/wiki/Covariant_return_type
@end

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Various UI Components
#pragma ------------------------------------------------------------------------------------------------------

@interface ChannelViewFeedToggleButton : UIButton
- (instancetype)initWithTitle:(NSString *)title;
@end

@interface ChannelViewerVoteScore : UIView
- (void)setPostModel:(Post *)postModel;
- (void)voteUp;
- (void)voteDown;
@end
