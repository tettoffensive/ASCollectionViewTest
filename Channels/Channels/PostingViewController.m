//
//  PostingViewController.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "PostingViewController.h"
#import "PBJVision.h"
#import <POP/POP.h>
#import "ChannelRecordVideoButton.h"
#import "ChannelsPostManager.h"
@import MediaPlayer;

static const double kMAX_VIDEO_DURATION = 6.0f;
static const NSString *kPBJVisionVideoCapturedDurationKey       = @"PBJVisionVideoCapturedDurationKey";
static const NSString *kPBJVisionVideoPathKey                   = @"PBJVisionVideoPathKey";
static const NSString *kPBJVisionVideoThumbnailArrayKey         = @"PBJVisionVideoThumbnailArrayKey";
static const NSString *kPBJVisionVideoThumbnailKey              = @"PBJVisionVideoThumbnailKey";

@interface PostingViewController () <PBJVisionDelegate, ChannelRecordVideoButtonDelegate, UIAlertViewDelegate>
{
    NSTimer *_videoDurationTimer;
    CFTimeInterval _startTime;
    
    UIButton *_closeButton;
    UIButton *_flashButton;
    UIButton *_switchCameraButton;
    
    PBJVision *_vision;
}

/*!
 *  Player responsible for playing the current channel's stream
 */
@property (nonatomic) MPMoviePlayerController *channelMoviePlayerController;

@property (nonatomic, assign) BOOL recording;

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, copy) NSString *captureSessionPreset;

@property (nonatomic) CGFloat videoBitRate;
@property (nonatomic) NSInteger audioBitRate;
@property (nonatomic) NSDictionary *additionalCompressionProperties;

@property (nonatomic) NSDictionary *currentVideo;

@property (nonatomic, strong) ChannelRecordVideoButton *recordVideoButton;

@end

@implementation PostingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // preview and AV layer
    _previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    _previewView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_previewView];
    
    CGRect previewFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(_previewView.frame), CGRectGetHeight(_previewView.frame));
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    [self setupCameraControls];
    
    // Setup Video
    [self setup];
    
    [self.view setY:screenHeight()];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view setY:0.0f];
    } completion:nil];
}

- (void)loadMoviePlayer
{
    NSURL *movieURL = [NSURL fileURLWithPath:[_currentVideo objectForKey:kPBJVisionVideoPathKey] isDirectory:NO];
    if (movieURL.absoluteString.length > 0) {
        [self.channelMoviePlayerController setContentURL:movieURL];
        [self.channelMoviePlayerController play];
        [self.view bringSubviewToFront:self.channelMoviePlayerController.view];
        [self.view bringSubviewToFront:_closeButton];
    }
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
        [self subscribeToNotificationsForPlayer:player];
        player;
    }) : _channelMoviePlayerController;
}

- (void)setupCameraControls
{
    // New Record Button
    _recordVideoButton = [[ChannelRecordVideoButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
    _recordVideoButton.delegate = self;
    [_recordVideoButton setCenter:self.view.center];
    [_recordVideoButton setFrame:CGRectOffset(_recordVideoButton.frame, 0.0f, self.view.bounds.size.height / 2.0f - 60.0f)];
    [self.view addSubview:_recordVideoButton];
    
    // Close Button
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    [_closeButton setImage:[UIImage imageNamed:@"Close Button"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(dismissPostingViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
    // Flash Button
    UIImage *flashIcon = [UIImage imageNamed:@"Flash Off"];
    CGFloat buttonOffsetX = flashIcon.size.width;
    _flashButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonOffsetX,
                                                              _recordVideoButton.center.y - (flashIcon.size.height / 2.0),
                                                              flashIcon.size.width,
                                                              flashIcon.size.height)];
    [_flashButton setImage:flashIcon forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(flash) forControlEvents:UIControlEventTouchUpInside];
    [_flashButton setTag:PostingViewFlashStateOff];
    [self.view addSubview:_flashButton];
    
    // Switch Camera Button
    UIImage *switchCameraIcon = [UIImage imageNamed:@"Switch Camera"];
    _switchCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - switchCameraIcon.size.width - buttonOffsetX,
                                                                     _recordVideoButton.center.y - (switchCameraIcon.size.height / 2.0),
                                                                     switchCameraIcon.size.width,
                                                                     switchCameraIcon.size.height)];
    [_switchCameraButton setImage:switchCameraIcon forState:UIControlStateNormal];
    [_switchCameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    [_switchCameraButton setTag:PostingViewCameraModeBack];
    [self.view addSubview:_switchCameraButton];
}

- (void)dismissPostingViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Video Capture
#pragma -------------------------------------------------------------------------------------------

- (void)setup
{
    _vision = [PBJVision sharedInstance];
    _vision.delegate = self;
    _vision.cameraMode = PBJCameraModeVideo;
    _vision.cameraOrientation = PBJCameraOrientationPortrait;
    _vision.focusMode = PBJFocusModeContinuousAutoFocus;
    _vision.outputFormat = PBJOutputFormatPreset;
    [_vision startPreview];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    _currentVideo = [videoDict copy];
    double videoDuration = [[_currentVideo objectForKey:kPBJVisionVideoCapturedDurationKey] doubleValue];
    if (videoDuration >= 1.0) {
        [self loadMoviePlayer];
        [self showconfirmUploadDialog];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Oops..."
                                  message:@"Video must be at least one second long."
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Confirm Upload Alert View
#pragma -------------------------------------------------------------------------------------------

- (void)showconfirmUploadDialog
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Confirm Upload"
                              message:@"Do you want to upload this video?"
                              delegate:self
                              cancelButtonTitle:@"No"
                              otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self pauseMovie];
    [self.channelMoviePlayerController.view removeFromSuperview];
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self uploadVideo:_currentVideo];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissPostingViewController];
        });
    }
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Upload Videos
#pragma -------------------------------------------------------------------------------------------

- (void)uploadVideo:(NSDictionary *)videoDictionary
{
    [[ChannelsPostManager sharedInstance] uploadVideo:_currentVideo];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Record Button Delegate Methods
#pragma -------------------------------------------------------------------------------------------

- (void)didStartRecording
{
    if (!_recording) {
        _recording = YES;
        [self startTrackingVideoDuration];
        [[PBJVision sharedInstance] startVideoCapture];
    }
}

- (void)didEndRecording
{
    _recording = NO;
    [self endTrackingVideoDuration];
    [[PBJVision sharedInstance] endVideoCapture];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Video Duration Tracking
#pragma -------------------------------------------------------------------------------------------

- (void)startTrackingVideoDuration
{
    _videoDurationTimer = [NSTimer scheduledTimerWithTimeInterval:0.005
                                                           target:self
                                                         selector:@selector(checkVideoDuration)
                                                         userInfo:nil
                                                          repeats:YES];
    _startTime = CACurrentMediaTime();
}

- (void)checkVideoDuration
{
    CFTimeInterval currentTime = CACurrentMediaTime() - _startTime;
    if (currentTime >= kMAX_VIDEO_DURATION) {
        [_recordVideoButton stopRecording];
    }
}

- (void)endTrackingVideoDuration
{
    [_videoDurationTimer invalidate];
    _videoDurationTimer = nil;
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Camera Controls
#pragma -------------------------------------------------------------------------------------------

- (void)flash
{
    if (_flashButton.tag == PostingViewFlashStateOff) {
        _flashButton.tag = PostingViewFlashStateOn;
        [_flashButton setImage:[UIImage imageNamed:@"Flash On"] forState:UIControlStateNormal];
        _vision.flashMode = PBJFlashModeOn;
    } else {
        _flashButton.tag = PostingViewFlashStateOff;
        [_flashButton setImage:[UIImage imageNamed:@"Flash Off"] forState:UIControlStateNormal];
        _vision.flashMode = PBJFlashModeOff;
    }
}

- (void)switchCamera
{
    if (_switchCameraButton.tag == PostingViewCameraModeBack) {
        _switchCameraButton.tag = PostingViewCameraModeFront;
        _vision.cameraDevice = PBJCameraDeviceFront;
    } else {
        _switchCameraButton.tag = PostingViewCameraModeBack;
        _vision.cameraDevice = PBJCameraDeviceBack;
    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackDidFinish:)    name:MPMoviePlayerPlaybackDidFinishNotification        object:player];
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
    POLYLog(@"%@", self.channelMoviePlayerController);
    [self loadMoviePlayer];
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

- (void)playMovie
{
    [self.channelMoviePlayerController play];
}

- (void)pauseMovie
{
    [self.channelMoviePlayerController pause];
}

@end
