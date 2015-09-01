//
//  ChannelViewController.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ChannelViewController.h"
#import "ChannelsInterface.h"

@implementation ChannelViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Channels";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setNavigationBarAppearance];
    self.view.backgroundColor = [ChannelsInterface viewBackgroundColor];
    
    [self loadMovie];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBarAppearance
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self setNeedsStatusBarAppearanceUpdate]; // Ask the system to re-query our -preferredStatusBarStyle.
}

- (void)loadMovie
{
    NSURL *movieURL = [NSURL URLWithString:@"http://channels-stage.videos.output.oregon.s3.amazonaws.com/y2T1waY0Smufhp8fQT4c91jE.m3u8"];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    if (player) {
        [player setMovieSourceType:MPMovieSourceTypeStreaming];
        [player setControlStyle:MPMovieControlStyleNone];
        [player setRepeatMode:MPMovieRepeatModeOne];
        [player setScalingMode:MPMovieScalingModeAspectFill];
        [player prepareToPlay];
        player.view.frame = self.view.bounds;
        [self.view addSubview:player.view];
        [player setFullscreen:NO];
        [player play];
        
//        [self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor magentaColor] andSize:self.view.frame.size]]];
        self.channelMoviePlayerController = player;
    }
}

@end
