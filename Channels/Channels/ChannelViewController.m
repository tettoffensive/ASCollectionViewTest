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
@import KVOController.FBKVOController;

@interface ChannelViewController ()
/*!
 *  Player responsible for playing the current channel's stream
 */
@property (nonatomic) MPMoviePlayerController *channelMoviePlayerController;
@end

@implementation ChannelViewController

- (instancetype)initWithViewModel:(ChannelPlayerViewModel *)viewModel
{
    if (self = [super init]) {
        NSParameterAssert(viewModel);
        [self reloadDataWithModel:viewModel]; // sets the view model
    }
    return self;
}

- (void)dealloc
{
    [self unsubscribeFromNotifications];
    [self.KVOControllerNonRetaining unobserveAll];
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
    
}

- (void)movieReadyForDisplay:(NSNotification*)notification
{
    
}

- (void)movieLoadStateDidChange:(NSNotification*)notification
{
    
}

- (void)movieNowPlayingDidChange:(NSNotification*)notification
{
    
}

- (void)moviePlaybackStateChange:(NSNotification*)notification
{
    
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ViewModel Observing
#pragma -------------------------------------------------------------------------------------------

- (void)setupObservers
{
    [self.KVOControllerNonRetaining observe:self.viewModel keyPath:@"title"
                                    options:NSKeyValueObservingOptionNew
                                      block:^(ChannelViewController *observer, ChannelPlayerViewModel *viewModel, NSDictionary *change) {
                                          [observer reloadDataWithModel:viewModel];
                                      }];
    
}

- (void)reloadDataWithModel:(ChannelPlayerViewModel *)viewModel
{
    if (self.viewModel != viewModel) {
        [self.KVOControllerNonRetaining unobserveAll];
        self.viewModel = viewModel;
        [self setupObservers];
    }
    
    [self setTitle:self.viewModel.title];
}

@end
