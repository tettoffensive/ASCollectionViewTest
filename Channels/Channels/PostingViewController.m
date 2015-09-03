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

static const NSString *kPBJVisionVideoCapturedDurationKey       = @"PBJVisionVideoCapturedDurationKey";
static const NSString *kPBJVisionVideoPathKey                   = @"PBJVisionVideoPathKey";
static const NSString *kPBJVisionVideoThumbnailArrayKey         = @"PBJVisionVideoThumbnailArrayKey";
static const NSString *kPBJVisionVideoThumbnailKey              = @"PBJVisionVideoThumbnailKey";

@interface PostingViewController () <PBJVisionDelegate, ChannelRecordVideoButtonDelegate>
{
    UIView *_recordVideoButtonStatusView;
}

@property (nonatomic, assign) BOOL recording;

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, copy) NSString *captureSessionPreset;

@property (nonatomic) CGFloat videoBitRate;
@property (nonatomic) NSInteger audioBitRate;
@property (nonatomic) NSDictionary *additionalCompressionProperties;

@property (nonatomic) NSDictionary *currentVideo;

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
    
    // New Record Button
    ChannelRecordVideoButton *recordVideoButton = [[ChannelRecordVideoButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
    recordVideoButton.delegate = self;
    [recordVideoButton setCenter:self.view.center];
    [recordVideoButton setFrame:CGRectOffset(recordVideoButton.frame, 0.0f, self.view.bounds.size.height / 2.0f - 60.0f)];
    [self.view addSubview:recordVideoButton];
    
    // Close Button
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    [closeButton setImage:[UIImage imageNamed:@"Close Button"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissPostingViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    // Setup Video
    [self setup];
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
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Video Capture
#pragma -------------------------------------------------------------------------------------------

- (void)setup
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    [vision startPreview];
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
    [self uploadVideo:_currentVideo];
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
        [[PBJVision sharedInstance] startVideoCapture];
    } else {
        _recording = YES;
        [[PBJVision sharedInstance] resumeVideoCapture];
    }
}

- (void)didEndRecording
{
    _recording = NO;
    [[PBJVision sharedInstance] endVideoCapture];
}

@end
