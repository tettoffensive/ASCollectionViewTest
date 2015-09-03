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
#import "PostingViewController.h"
#import "PostingViewModel.h"

@import MediaPlayer;

@interface ChannelViewController ()
/*!
 *  Player responsible for playing the current channel's stream
 */
@property (nonatomic) MPMoviePlayerController *channelMoviePlayerController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger count;
@property (nonatomic, strong) UIButton *postButton;

@end

@implementation ChannelViewController

- (instancetype)initWithViewModel:(POLYViewModel *)viewModel
{
    if (self = [super initWithViewModel:viewModel]) {
        NSParameterAssert([viewModel isKindOfClass:[ChannelPlayerViewModel class]]);
    }
    return self;
}

- (void)dealloc
{
    [self unsubscribeFromNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadMovie];
    
    UIImage *postButtonImage = [UIImage imageNamed:@"Camera Button"];
    _postButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, postButtonImage.size.width, postButtonImage.size.height)];
    [_postButton setCenter:self.view.center];
    [_postButton setFrame:CGRectOffset(_postButton.frame, 0.0f, self.view.bounds.size.height/2.0 - 60.0f)];
    [_postButton setImage:postButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_postButton];
    [_postButton addTarget:self action:@selector(showPostViewController) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:_postButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pauseMovie];
}

- (MPMoviePlayerController *)channelMoviePlayerController
{
    return !_channelMoviePlayerController ? _channelMoviePlayerController =
    ({
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] init];
        [player setFullscreen:NO];
        [player setMovieSourceType:MPMovieSourceTypeStreaming];
        [player setControlStyle:MPMovieControlStyleNone];
        [player setRepeatMode:MPMovieRepeatModeOne];
        [player setScalingMode:MPMovieScalingModeAspectFill];
        [player.view setFrame:self.view.bounds];
        [self.view addSubview:player.view];
        [self subscribeToNotificationsForPlayer:player];
        player;
    }) : _channelMoviePlayerController;
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - MPMoviePlayerController Notifications
#pragma -------------------------------------------------------------------------------------------

- (void)unsubscribeFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)subscribeToNotificationsForPlayer:(MPMoviePlayerController*)player
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDurationAvailable:)    name:MPMovieDurationAvailableNotification              object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieReadyForDisplay:)      name:MPMoviePlayerReadyForDisplayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:)   name:MPMoviePlayerLoadStateDidChangeNotification       object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieNowPlayingDidChange:)  name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateChange:)  name:MPMoviePlayerPlaybackStateDidChangeNotification   object:player];
}

- (void)movieDurationAvailable:(NSNotification*)notification
{
    POLYLog(@"%d",self.channelMoviePlayerController.duration);
}

- (void)movieReadyForDisplay:(NSNotification*)notification
{
    POLYLog(@"%@",self.channelMoviePlayerController.readyForDisplay ? @"YES" : @"NO");
}

- (void)movieLoadStateDidChange:(NSNotification*)notification
{
    // Network Load State of the movie player (Unknown, Playable, PlaythroughOK, Stalled)
    POLYLog(@"%u",self.channelMoviePlayerController.loadState);
}

- (void)movieNowPlayingDidChange:(NSNotification*)notification
{
    // Posted when the currently playing movie has changed. There is no userInfo dictionary.
    POLYLog(@"%@", self.channelMoviePlayerController.contentURL);
    
    
}

- (void)moviePlaybackStateChange:(NSNotification*)notification
{
    // Stopped, Playing, Paused, Interrupted, Seeking Forward, Seeking Backward
    POLYLog(@"%u",self.channelMoviePlayerController.playbackState);
    
    switch (self.channelMoviePlayerController.playbackState) {
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped: {
            self.index = (self.count > 0) ? ((self.index + 1) % self.count) : 0;
            [self loadMovie];
            break;
        }
        case MPMoviePlaybackStatePlaying: {
            break;
        }
        case MPMoviePlaybackStateInterrupted: {
            break;
        }
        case MPMoviePlaybackStateSeekingForward: {
            break;
        }
        case MPMoviePlaybackStateSeekingBackward: {
            break;
        }
        default: {
            break;
        }
    }
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ViewModel
#pragma -------------------------------------------------------------------------------------------

- (void)reloadData
{
    if ([self.viewModel isKindOfClass:[ChannelPlayerViewModel class]]) {
        ChannelPlayerViewModel *viewModel = (ChannelPlayerViewModel*)self.viewModel;
        [self setTitle:viewModel.channelTitle];
        [self setCount:[viewModel.channelPosts count]];
        
        if (self.channelMoviePlayerController.loadState == MPMovieLoadStateUnknown) {
            [self loadMovie];
        }
    }
}

- (void)loadMovie
{
    if ([self.viewModel isKindOfClass:[ChannelPlayerViewModel class]]) {
        ChannelPlayerViewModel *viewModel = (ChannelPlayerViewModel*)self.viewModel;
        NSURL *movieURL = [NSURL URLWithString:viewModel.channelPosts[self.index]];
        if (![movieURL.absoluteString isEqualToString:self.channelMoviePlayerController.contentURL.absoluteString]) {
            [self.channelMoviePlayerController setContentURL:movieURL];
            [self.channelMoviePlayerController prepareToPlay];
        }
        if ([self.channelMoviePlayerController.contentURL.absoluteString length] > 0) {
            [self.channelMoviePlayerController play];
        }
    }
}

- (void)pauseMovie
{
    [self.channelMoviePlayerController pause];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Posting View Controller
#pragma -------------------------------------------------------------------------------------------

- (void)showPostViewController
{
    PostingViewModel *postingViewModel = [[PostingViewModel alloc] init];
    PostingViewController *postViewController = [[PostingViewController alloc] initWithViewModel:postingViewModel];
    [self.navigationController presentViewController:postViewController animated:YES completion:NULL];
}

@end
