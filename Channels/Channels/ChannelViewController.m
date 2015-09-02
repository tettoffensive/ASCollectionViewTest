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

@import MediaPlayer;

@interface ChannelViewController ()
/*!
 *  Player responsible for playing the current channel's stream
 */
@property (nonatomic) MPMoviePlayerController *channelMoviePlayerController;
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
    
    [self setNavigationBarAppearance];
    self.view.backgroundColor = [ChannelsInterface viewBackgroundColor];
    
    [self loadMovie];
}

- (void)setNavigationBarAppearance
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self setNeedsStatusBarAppearanceUpdate]; // Ask the system to re-query our -preferredStatusBarStyle.
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
        [self subscribeToNotificationsForPlayer:player];
        player;
    }) : _channelMoviePlayerController;
}

- (void)loadMovie
{
    NSURL *movieURL = [NSURL URLWithString:@"http://channels-stage.videos.output.oregon.s3.amazonaws.com/7BE9A1E0-A430-45D1-8CC2-2D83253AEC69.m3u8"];
    [self.channelMoviePlayerController setContentURL:movieURL];
    [self.channelMoviePlayerController prepareToPlay];
    [self.view addSubview:self.channelMoviePlayerController.view];
    [self.channelMoviePlayerController play];
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
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ViewModel
#pragma -------------------------------------------------------------------------------------------

- (void)reloadData
{
    if ([self.viewModel isKindOfClass:[ChannelPlayerViewModel class]]) {
        [self setTitle:((ChannelPlayerViewModel*)self.viewModel).channelTitle];
    }
}

@end
