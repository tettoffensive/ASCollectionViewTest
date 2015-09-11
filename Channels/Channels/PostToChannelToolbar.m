//
//  PostToChannelToolbar.m
//  Channels
//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "PostToChannelToolbar.h"
#import "ChannelsInterface.h"
#import "ChannelsPostManager.h"
#import "POLYActivityIndicator.h"

@interface PostToChannelToolbar()

@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) POLYActivityIndicator *activityIndicator;

@end

@implementation PostToChannelToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _viewContainer = [[UIView alloc] initWithFrame:self.bounds];
        _viewContainer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
        [self addSubview:_viewContainer];
        
        _titleLabel = [[UILabel alloc] initWithFrame:_viewContainer.bounds];
        [_titleLabel setText:@"Pick channel"];
        [_titleLabel setTextColor:[ChannelsInterface channelsGreyColor]];
        [_titleLabel setFont:[ChannelsInterface mediumFontOfSize:16.0]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel sizeToFit];
        _titleLabel.center = CGPointMake(_viewContainer.bounds.size.width/2.0, _viewContainer.bounds.size.height/2.0);
        [_viewContainer addSubview:_titleLabel];
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(_viewContainer.bounds.origin.x,
                                                                 _viewContainer.bounds.origin.y,
                                                                 50.0f, 50.0f)];
        [_leftButton setImage:[UIImage imageNamed:@"Pick Channel"] forState:UIControlStateNormal];
        [_viewContainer addSubview:_leftButton];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(_viewContainer.bounds.size.width - 50.0f,
                                                                  _viewContainer.bounds.origin.y,
                                                                  50.0f, 50.0f)];
        [_rightButton setImage:[UIImage imageNamed:@"Post To Channel"] forState:UIControlStateNormal];
        [_rightButton setEnabled:NO];
        [_viewContainer addSubview:_rightButton];
        
        
        // Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadDidStart:)
                                                     name:ChannelsPostManagerDidStartUploadNotification
                                                   object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(uploadProgress:)
//                                                     name:ChannelsPostManagerDidUpdateUploadProgressNotification
//                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadDidComplete:)
                                                     name:ChannelsPostManagerDidCompleteUploadNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadDidFail:)
                                                     name:ChannelsPostManagerDidFailUploadNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateToolbarTitle:(NSString *)title
{
    [_titleLabel setText:title];
    [_titleLabel sizeToFit];
    _titleLabel.center = CGPointMake(_viewContainer.bounds.size.width/2.0, _viewContainer.bounds.size.height/2.0);
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Upload Notifications
#pragma -------------------------------------------------------------------------------------------

- (void)uploadDidStart:(NSNotification *)notification
{
    [_rightButton setHidden:YES];
    
    _activityIndicator = [[POLYActivityIndicator alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0f, 50.0f)];
    [_activityIndicator setFrame:CGRectMake(_viewContainer.bounds.size.width - _activityIndicator.bounds.size.width,
                                            _viewContainer.bounds.origin.y,
                                            _activityIndicator.bounds.size.width,
                                            _activityIndicator.bounds.size.height)];
    [_viewContainer addSubview:_activityIndicator];
    [_activityIndicator start];
}

- (void)uploadDidComplete:(NSNotification *)notification
{
    [_activityIndicator stopWithCompletion:YES];
}

- (void)uploadDidFail:(NSNotification *)notification
{
    [_activityIndicator stopWithCompletion:YES];

    // NEED TO HANDLE FAIL STATE
}

@end