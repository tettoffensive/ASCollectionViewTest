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
@import KVOController;

@interface ChannelViewController ()
/*!
 *  Player responsible for playing the current channel's stream
 */
@property (nonatomic) MPMoviePlayerController *channelMoviePlayerController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger count;
@property (nonatomic, strong) UIButton *postButton;
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

- (void)dealloc
{
    [self unsubscribeFromNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.postButton];
    [self.view addSubview:self.postTrackerLabel];
}

- (UIButton *)postButton
{
    return !_postButton ? _postButton =
    ({
        UIImage *postButtonImage = [UIImage imageNamed:@"Post Button"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, postButtonImage.size.width, postButtonImage.size.height)];
        [button setCenter:self.view.center];
        [button setFrame:CGRectOffset(button.frame, 0.0f, self.view.bounds.size.height/2.0 - 60.0f)];
        [button setImage:postButtonImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showPostViewController) forControlEvents:UIControlEventTouchUpInside];
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
        [value setFrame:CGRectMake(0, 0, screenWidth(), 16)];
        [value setFrame:CGRectOffset(value.frame, 10, screenHeight()-10.-value.frame.size.height)];
        [value.KVOController observe:self keyPaths:@[@"count",@"index"] options:NSKeyValueObservingOptionNew block:^(UILabel *observer, id object, NSDictionary *change) {
            [value setText:[self trackerString]];
        }];
//        [value applyScrimShadow];
        value;
    }) : _postTrackerLabel;
}

- (NSString *)trackerString
{
    NSUInteger index = MIN(self.index+1,self.count);
    return [NSString stringWithFormat:@"%lu  /  %lu", index, self.count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:_postButton];
    [self playMovie];
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
        [player setRepeatMode:MPMovieRepeatModeNone];
        [player setScalingMode:MPMovieScalingModeAspectFill];
        [player.view setFrame:self.view.bounds];
        [self.view addSubview:player.view];
        [self.view sendSubviewToBack:player.view];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackDidFinish:)  name:MPMoviePlayerPlaybackDidFinishNotification   object:player];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setDelegate:self];
    [player.view addGestureRecognizer:tapGestureRecognizer];
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

- (void)moviePlaybackDidFinish:(NSNotification*)notification
{
    MPMovieFinishReason reason = (MPMovieFinishReason)[[notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] unsignedIntegerValue];
    
    if (reason != MPMovieFinishReasonUserExited) {
        if (self.count - self.index < 3) {
            // make a call to reload the posts if we are close to the last post
            [self.viewModel updatePosts];
        }
        self.index = (self.count > 0) ? ((self.index + 1) % self.count) : 0;
        [self loadMovie];
    }
}

- (void)moviePlaybackStateChange:(NSNotification*)notification
{
    // Stopped, Playing, Paused, Interrupted, Seeking Forward, Seeking Backward
    POLYLog(@"%u",self.channelMoviePlayerController.playbackState);
    
    switch (self.channelMoviePlayerController.playbackState) {
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped: {
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
    [self setTitle:self.viewModel.channelTitle];
    [self setCount:[self.viewModel.channelPosts count]];
    if (self.index >= self.count) {
        self.index = 0;
    }
    
    if (self.channelMoviePlayerController.loadState == MPMovieLoadStateUnknown) {
        [self loadMovie];
    }
}

- (void)loadMovie
{
    NSURL *movieURL = ([self.viewModel.channelPosts count] > 0) ? [NSURL URLWithString:self.viewModel.channelPosts[self.index]] : nil;
    if (![movieURL.absoluteString isEqualToString:self.channelMoviePlayerController.contentURL.absoluteString]) {
        [self.channelMoviePlayerController setContentURL:movieURL];
        [self.channelMoviePlayerController prepareToPlay];
    }
    if ([self.channelMoviePlayerController.contentURL.absoluteString length] > 0) {
        [self.channelMoviePlayerController play];
    }
}

- (void)playMovie
{
    [self.channelMoviePlayerController play];
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

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Gestures
#pragma -------------------------------------------------------------------------------------------

- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        self.index = (self.count > 0) ? ((self.index + 1) % self.count) : 0;
        [self loadMovie];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES; // MPMoviePlayerController's view intercepts the tap gesture if we don't do this
}


@end
