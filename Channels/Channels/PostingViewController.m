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

@interface PostingViewController () <PBJVisionDelegate>
{
    UIView *_recordVideoButtonStatusView;
}

@property (nonatomic, assign) BOOL recording;

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

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
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.minimumPressDuration = 1.0;
    
    // New Record Button
    ChannelRecordVideoButton *recordVideoButton = [[ChannelRecordVideoButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
    [recordVideoButton setCenter:self.view.center];
    [recordVideoButton setFrame:CGRectOffset(recordVideoButton.frame, 0.0f, self.view.bounds.size.height / 2.0f - 60.0f)];
    [self.view addSubview:recordVideoButton];
    [recordVideoButton addGestureRecognizer:_longPressGestureRecognizer];
    
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

- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!_recording) {
                _recording = YES;
                [[PBJVision sharedInstance] startVideoCapture];
            } else {
                _recording = YES;
                [[PBJVision sharedInstance] resumeVideoCapture];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            _recording = NO;
            [[PBJVision sharedInstance] endVideoCapture];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            _recording = NO;
            break;
        }
        case UIGestureRecognizerStateFailed:
        {
            _recording = NO;
            [[PBJVision sharedInstance] pauseVideoCapture];
            break;
        }
        default:
            break;
    }
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

- (void)uploadVideo:(NSDictionary *)videoDictionary
{
    [[ChannelsPostManager sharedInstance] uploadVideo:_currentVideo];
}

@end
