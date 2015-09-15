//
//  ChannelViewController.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ChannelViewController.h"
#import "ChannelsInterface.h"
#import "ChannelPlayerViewModel.h"
#import "ChannelVideoPlayerController.h"
#import <POP/POP.h>

@import KVOController;

@interface ChannelViewController ()<ChannelVideoPlayerControllerDelegate,ChannelVideoPlayerControllerDataSource>
{
    UIButton *_closeButton;
}
/*!
 *  Player responsible for playing the current channel's stream
 */
@property (nonatomic) ChannelVideoPlayerController *channelMoviePlayerController;
@property (nonatomic) NSUInteger count;
@property (nonatomic, strong) UILabel  *postTrackerLabel;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *postButton;

@property (nonatomic, strong) ChannelViewerVoteScore *votingScore;

@property (nonatomic, strong) ChannelViewFeedToggleButton *popularButton;
@property (nonatomic, strong) ChannelViewFeedToggleButton *recentButton;


@end

@implementation ChannelViewController

@dynamic viewModel; // required for covariant return type: https://en.wikipedia.org/wiki/Covariant_return_type

- (instancetype)initWithViewModel:(ChannelPlayerViewModel *)viewModel
{
    if (self = [super initWithViewModel:viewModel]) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.postTrackerLabel];
    [self.view addSubview:self.subscribeButton];
    [self.view addSubview:self.votingScore];
    [self.view addSubview:self.popularButton];
    [self.view addSubview:self.recentButton];
    [self.view addSubview:self.shareButton];
    [self.view addSubview:self.chatButton];
    [self.view addSubview:self.postButton];
    
    [self.popularButton setSelected:YES];
    
    // Close Button
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
    [_closeButton setImage:[UIImage imageNamed:@"Close Button"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton setAlpha:0.05f];
    [self.view addSubview:_closeButton];
    
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIButton *)postButton
{
    return !_postButton ? _postButton =
    ({
        CGFloat margin = 20.0f;
        UIImage *postButtonImage = [UIImage imageNamed:@"Camera Button"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, postButtonImage.size.width, postButtonImage.size.height)];
        [button setTransform:[button scaledTransformUsingSize:CGSizeMake(button.width * 0.8f, button.height * 0.8f)]];
        [button setFrame:CGRectMake(self.view.width - button.width - margin, self.view.height - button.height - margin, button.width, button.height)];
        [button setImage:postButtonImage forState:UIControlStateNormal];
        //[button addTarget:self action:@selector(showPostViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    }) : _postButton;
}

- (UILabel *)postTrackerLabel
{
    return !_postTrackerLabel ? _postTrackerLabel =
    ({
        UILabel *value = [UILabel new];
        [value setFont:[ChannelsInterface boldFontOfSize:16]];
        [value setTextColor:[UIColor whiteColor]];
        [value setNumberOfLines:1];
        [value setText:[self trackerString]];
        [value setTextAlignment:NSTextAlignmentCenter];
        [value setFrame:CGRectMake(0, 0, screenWidth(), 16)];
        [value setFrame:CGRectOffset(value.frame, 10, 25.0f)];
        [value setAlpha:0.0f];
        [value.KVOController observe:self
                             keyPath:@"count"
                             options:NSKeyValueObservingOptionNew
                               block:[self trackerStringBlock]];
        [value applyScrimShadow];
        value;
    }) : _postTrackerLabel;
}

- (UIButton *)subscribeButton
{
    return !_subscribeButton ? _subscribeButton =
    ({
        CGFloat margin = 20.0f;
        UIColor *color = [UIColor colorWithHexString:@"#ffd70d"];
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:[@"subscribe" uppercaseString] forState:UIControlStateNormal];
        [button setTitleColor:color forState:UIControlStateNormal];
        [button setContentEdgeInsets:UIEdgeInsetsMake(8.0f, 10.0f, 6.0f, 10.0f)];
        [button.titleLabel setFont:[ChannelsInterface boldFontOfSize:10.0f]];
        [button sizeToFit];
        [button setX:CGRectGetMaxX(self.view.frame) - button.width - margin];
        [button setY:margin];
        [button.layer setCornerRadius:3.0f];
        [button.layer setBorderWidth:2.0f];
        [button.layer setBorderColor:color.CGColor];
        button;
    }) : _subscribeButton;
}

- (UIButton *)shareButton
{
    return !_shareButton ? _shareButton =
    ({
        UIButton *button = [[UIButton alloc] initWithImageName:@"Channel Viewer Share Button"];
        [button setY:self.recentButton.y + 3.0f];
        [button setX:self.view.width/2 + 15.0f];
        button;
    }) : _shareButton;
}

- (UIButton *)chatButton
{
    return !_chatButton ? _chatButton =
    ({
        UIButton *button = [[UIButton alloc] initWithImageName:@"Channel Viewer Chat Button"];
        [button setY:self.recentButton.y + 5.0f];
        [button setX:CGRectGetMaxX(self.shareButton.frame) + 20.0f];
        button;
    }) : _chatButton;
}

- (ChannelViewFeedToggleButton *)popularButton
{
    return !_popularButton ? _popularButton =
    ({
        CGFloat margin = 25.0f;
        ChannelViewFeedToggleButton *button = [[ChannelViewFeedToggleButton alloc] initWithTitle:@"popular"];
        [button setX:margin];
        [button setY:self.view.height - button.height - margin - 12.0f];
        button;
    }) : _popularButton;
}

- (ChannelViewFeedToggleButton *)recentButton
{
    return !_recentButton ? _recentButton =
    ({
        CGFloat margin = 25.0f;
        ChannelViewFeedToggleButton *button = [[ChannelViewFeedToggleButton alloc] initWithTitle:@"recent"];
        [button setX:CGRectGetMaxX(self.popularButton.frame)];
        [button setY:self.view.height - button.height - margin - 12.0f];
        button;
    }) : _recentButton;
}

- (ChannelViewerVoteScore *)votingScore
{
    return !_votingScore ? _votingScore =
    ({
        ChannelViewerVoteScore *votingScore = [ChannelViewerVoteScore new];
        votingScore;
    }) : _votingScore;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - KVO
#pragma ------------------------------------------------------------------------------------------------------

- (FBKVONotificationBlock)trackerStringBlock
{
    FBKVONotificationBlock trackerStringBlock = ^(UILabel *observer, id object, NSDictionary *change) {
        [observer setText:[self trackerString]];
        Post *post = self.viewModel.channelPosts[_channelMoviePlayerController.currentItemIndex];
        [self.votingScore setPostModel:post];
    };
    return [trackerStringBlock copy];
}

- (NSString *)trackerString
{
    NSUInteger index = MIN(_channelMoviePlayerController.currentItemIndex+1,self.count);
    return [NSString stringWithFormat:@"%lu  /  %lu", index, self.count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self playMovie];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pauseMovie];
}

- (ChannelVideoPlayerController *)channelMoviePlayerController
{
    return !_channelMoviePlayerController ? _channelMoviePlayerController =
    ({
        ChannelVideoPlayerController *player = [ChannelVideoPlayerController new];
        [player.view setUserInteractionEnabled:NO];
        [player setDelegate:self];
        [player setDataSource:self];
        [player.view setFrame:self.view.bounds];
        [player.view setUserInteractionEnabled:NO];
        [player setVideoFillMode:AVLayerVideoGravityResizeAspectFill]; // order important. must do AFTER setFrame
        [self.view addSubview:player.view];
        [player didMoveToParentViewController:self];
        [self.view sendSubviewToBack:player.view];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [tapGestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:tapGestureRecognizer];
        
        [self.postTrackerLabel.KVOController observe:player
                                             keyPath:@"currentItemIndex"
                                             options:NSKeyValueObservingOptionNew
                                               block:[self trackerStringBlock]];
        
        player;
    }) : _channelMoviePlayerController;
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ChannelVideoPlayerControllerDelegate
#pragma -------------------------------------------------------------------------------------------

- (void)videoPlayerReady:(ChannelVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerPlaybackStateDidChange:(ChannelVideoPlayerController *)videoPlayer
{
    switch (videoPlayer.playbackState) {
        case ChannelVideoPlayerPlaybackStateStopped:
        case ChannelVideoPlayerPlaybackStatePlaying:
        case ChannelVideoPlayerPlaybackStatePaused:
            break;
        case ChannelVideoPlayerPlaybackStateFailed: {
            break;
        }
        default:
            break;
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(ChannelVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerPlaybackDidEnd:(ChannelVideoPlayerController *)videoPlayer
{
    if (self.count - self.channelMoviePlayerController.currentItemIndex < 3) {
        // make a call to reload the posts if we are close to the last post
        [self.viewModel updatePostsForCurrentChannel];
    }
}

- (void)videoPlayerBufferringStateDidChange:(ChannelVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerWillPlayNextItem
{
    [[self getCurrentPostModel] sendVote];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ViewModel
#pragma -------------------------------------------------------------------------------------------

- (void)reloadData
{
    [self setTitle:self.viewModel.channelTitle];
    [self setCount:[self.viewModel.channelPosts count]];
    
    if (self.channelMoviePlayerController.bufferingState == ChannelVideoPlayerBufferingStateUnknown) {
        [self.channelMoviePlayerController playCurrentMedia];
    }
}

- (NSURL *)videoPlayer:(ChannelVideoPlayerController *)player playerItemAtIndex:(NSInteger)index
{
    if (self.viewModel.channelPosts.count > index) {
        return self.viewModel.channelPosts[index].URL;
    }
    return nil;
}

- (NSURL *)videoPlayer:(ChannelVideoPlayerController *)player thumbnailItemAtIndex:(NSInteger)index
{
    if (self.viewModel.channelPosts.count > index) {
        return self.viewModel.channelPosts[index].thumbnailURL;
    }
    return nil;
}

- (NSUInteger)numberOfPlayerItems
{
    return self.viewModel.channelPosts.count;
}

- (void)playMovie
{
    [self.channelMoviePlayerController resume];
}

- (void)pauseMovie
{
    [self.channelMoviePlayerController pause];
}

- (Post *)getCurrentPostModel
{
    return self.viewModel.channelPosts[self.channelMoviePlayerController.currentItemIndex];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Gestures
#pragma -------------------------------------------------------------------------------------------

- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:self.channelMoviePlayerController.view];
    if (tap.state == UIGestureRecognizerStateEnded) {
        
        CGFloat navWidth = 100.0f;
        
        if (touchPoint.x > 0 && touchPoint.x <= navWidth) {
            [self.channelMoviePlayerController previous];
        }
        
        else if (touchPoint.x >= self.channelMoviePlayerController.view.width - navWidth && touchPoint.x <= self.channelMoviePlayerController.view.width) {
            [self.channelMoviePlayerController next];
        }
        
        else {
        
            if (touchPoint.y < screenHeight()/2) {
                [self.votingScore voteUp];
                [self.viewModel.channelPosts[self.channelMoviePlayerController.currentItemIndex] voteUp];
            } else {
                [self.votingScore voteDown];
                [self.viewModel.channelPosts[self.channelMoviePlayerController.currentItemIndex] voteDown];
            }
        }
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Various UI Components that make up of this page
#pragma ------------------------------------------------------------------------------------------------------

@interface ChannelViewFeedToggleButton()
@property UIImageView *lineView;
@end

@implementation ChannelViewFeedToggleButton

- (instancetype)initWithTitle:(NSString *)title
{
    CGFloat height = 40.0f;
    
    if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, height)]) {
        [self setTitle:[title uppercaseString] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8f] forState:UIControlStateNormal];
        //[self setImage:UIQueryImage(@"Channel Viewer Toggle Selected") forState:UIControlStateNormal];
        [self sizeToFit];
        [self.titleLabel setFont:[ChannelsInterface boldFontOfSize:11]];
        
        self.lineView = UIQueryImageView(@"Channel Viewer Toggle Selected");
        [self addSubview:self.lineView];
        [self.lineView centerAlign];
        [self.lineView setY:CGRectGetMaxY(self.frame) - self.lineView.height - 5.0f];
        [self.lineView setHidden:YES];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self.lineView setHidden:NO];
}

@end

@interface ChannelViewerVoteScore()

@property (nonatomic, strong) Post *postModel;
@property (nonatomic, strong) UILabel  *scoreLabel;
@property (nonatomic, strong) UIView   *scoreBar;
@property (nonatomic, strong) UIImageView *awwwTheHeart;
@end

@implementation ChannelViewerVoteScore

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth(), screenHeight())]) {
        [self addSubview:self.scoreBar];
        [self addSubview:self.scoreLabel];
        [self addSubview:self.awwwTheHeart];
        [self setHidden:YES];
    }
    return self;
}

- (void)setPostModel:(Post *)postModel
{
    NSInteger numberOfVotesUp = [postModel numberOfVotesUp];
    //NSInteger numberOfVotesDown = [postModel numberOfVotesDown];
    [self setHidden:NO];
    [self setScore:numberOfVotesUp];
}

- (void)setScore:(NSInteger)score
{
    [self.scoreLabel setText:[NSString stringWithFormat:@"%ld", (long)score]];
    [self.scoreLabel sizeToFit];
    [self.scoreLabel middleAlign];
    
    [self.scoreBar setHeight:(self.height/2) + 10.0f];
    [self.scoreBar setY:self.height - self.scoreBar.height];
    
    [self.awwwTheHeart setX:CGRectGetMaxX(self.scoreLabel.frame) + 5.0f];
    [self.awwwTheHeart setY:self.scoreLabel.y];
    
    [self applyRoundedCornersForVoteScoreBar];
}

- (void)voteUp
{
    NSInteger currentVotingScore = [self.scoreLabel.text integerValue];
    currentVotingScore++;
    [self setScore:currentVotingScore];
    [self showThatCheesyHeartAnimation];
}

- (void)voteDown
{
    NSInteger currentVotingScore = [self.scoreLabel.text integerValue];
    currentVotingScore--;
    [self setScore:currentVotingScore];
}

- (void)showThatCheesyHeartAnimation
{
    UIImageView *view = UIQueryImageView(@"Channel Viewer Vote Bar Heart");
    [view setX:self.awwwTheHeart.x];
    [view setY:self.awwwTheHeart.y];
    [self addSubview:view];
    
    POPBasicAnimation *positionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    positionAnimation.toValue = @(view.y - 30.0f);
    [view.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    
    CGSize size = CGSizeMake(2.0f, 2.0f);
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:size];
    scaleAnimation.duration = 0.25f;
    [view.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.0f);
    [view pop_addAnimation:alphaAnimation forKey:@"alphaAnim"];
    
    // Circle
    
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(-50.0f/2, self.height/2 - 30.0f, 50.0f, 50.0f)];
    circle.layer.cornerRadius = 25.0f;
    circle.backgroundColor = [UIColor colorWithHexString:@"#11b356"];
    [self insertSubview:circle belowSubview:self.scoreBar];
    
    POPBasicAnimation *alphaAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnimation2.fromValue = @(1.0f);
    alphaAnimation2.toValue = @(0.8f);
    alphaAnimation2.beginTime = CACurrentMediaTime() + 0.2f;
    [circle pop_addAnimation:alphaAnimation2 forKey:@"alphaAnim"];
    
    POPBasicAnimation *scaleAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation2.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.2f, 0.2f)];
    scaleAnimation2.toValue = [NSValue valueWithCGSize:CGSizeMake(1.5f, 1.5f)];
    scaleAnimation2.duration = 0.25f;
    [circle.layer pop_addAnimation:scaleAnimation2 forKey:@"scaleAnimation"];
    
    POLYDispatchAfter(0.2f, ^{
        UIView *circle2 = [[UIView alloc] initWithFrame:CGRectMake(-50.0f/2, self.height/2 - 30.0f, 50.0f, 50.0f)];
        circle2.layer.cornerRadius = 25.0f;
        circle2.backgroundColor = [UIColor colorWithHexString:@"#0d8e44"];
        [self insertSubview:circle2 belowSubview:circle];
        
        POPBasicAnimation *alphaAnimation3 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation3.fromValue = @(1.0f);
        alphaAnimation3.toValue = @(0.2f);
        alphaAnimation3.beginTime = CACurrentMediaTime() + 0.05f;
        [circle2 pop_addAnimation:alphaAnimation3 forKey:@"alphaAnim"];
        
        POPBasicAnimation *scaleAnimation3 = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation3.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.2f, 0.2f)];
        scaleAnimation3.toValue = [NSValue valueWithCGSize:CGSizeMake(2.0f, 2.0f)];
        scaleAnimation3.duration = 0.25f;
        [circle2.layer pop_addAnimation:scaleAnimation3 forKey:@"scaleAnimation"];
        
        
        POLYDispatchAfter(0.2f, ^{
            POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
            alphaAnimation.toValue = @(0.0f);
            alphaAnimation.beginTime = CACurrentMediaTime() + 0.2f;
            [circle pop_addAnimation:alphaAnimation forKey:@"alphaAnim"];
            
            POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.7f, 1.7f)];
            scaleAnimation.duration = 0.25f;
//            [circle.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
            
            POPBasicAnimation *alphaAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
            alphaAnimation2.toValue = @(0.0f);
            alphaAnimation2.beginTime = CACurrentMediaTime() + 0.2f;
            [circle2 pop_addAnimation:alphaAnimation2 forKey:@"alphaAnim"];
            
            POPBasicAnimation *scaleAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            scaleAnimation2.toValue = [NSValue valueWithCGSize:CGSizeMake(2.2f, 2.2f)];
            scaleAnimation2.duration = 0.25f;
//            [circle2.layer pop_addAnimation:scaleAnimation2 forKey:@"scaleAnimation"];
        });
    });
}

- (UIView *)scoreBar
{
    return !_scoreBar ? _scoreBar =
    ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        [view setBackgroundColor:[UIColor colorWithHexString:@"#40ca78"]];
        view;
    }) : _scoreBar;
}

- (UIImageView *)awwwTheHeart
{
    return !_awwwTheHeart ? _awwwTheHeart =
    ({
        UIImageView *view = UIQueryImageView(@"Channel Viewer Vote Bar Heart");
        view;
    }) : _awwwTheHeart;
}

- (UILabel *)scoreLabel
{
    return !_scoreLabel ? _scoreLabel =
    ({
        UILabel *value = [UILabel new];
        [value setFont:[ChannelsInterface boldFontOfSize:16]];
        [value setTextColor:[UIColor whiteColor]];
        [value setNumberOfLines:1];
        [value setText:@""];
        [value setFrame:CGRectMake(10.0f, 0, screenWidth(), 16)];
        [value setFrame:CGRectOffset(value.frame, 5, screenHeight()-30.-value.frame.size.height)];
        [value applyScrimShadow];
        [value setClipsToBounds:NO];
        value;
    }) : _scoreLabel;
}

- (void)applyRoundedCornersForVoteScoreBar
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.scoreBar.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(5.0f, 5.0f)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.scoreBar.layer.mask = maskLayer;
}

@end
