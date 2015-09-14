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
    
    // Close Button
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    [_closeButton setImage:[UIImage imageNamed:@"Close Button"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
        [value setFrame:CGRectMake(0, 0, screenWidth(), 16)];
        [value setFrame:CGRectOffset(value.frame, 10, screenHeight()-10.-value.frame.size.height)];
        [value.KVOController observe:self
                             keyPath:@"count"
                             options:NSKeyValueObservingOptionNew
                               block:[self trackerStringBlock]];
        [value applyScrimShadow];
        value;
    }) : _postTrackerLabel;
}

- (FBKVONotificationBlock)trackerStringBlock
{
    FBKVONotificationBlock trackerStringBlock = ^(UILabel *observer, id object, NSDictionary *change) {
        [observer setText:[self trackerString]];
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
                [self.viewModel.channelPosts[self.channelMoviePlayerController.currentItemIndex] voteUp];
            } else {
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
