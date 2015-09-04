//
//  ChannelVideoPlayerController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//
//  Modified from: PBJVideoPlayerController.m
//
//  Created by Patrick Piemonte on 5/27/13.
//  Copyright (c) 2013-present, Patrick Piemonte, http://patrickpiemonte.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ChannelVideoPlayerController.h"
@import PBJVideoPlayer;
@import AVFoundation;

// KVO contexts
static NSString * const ChannelVideoPlayerObserverContext = @"ChannelVideoPlayerObserverContext";
static NSString * const ChannelVideoPlayerItemObserverContext = @"ChannelVideoPlayerItemObserverContext";
static NSString * const ChannelVideoPlayerLayerObserverContext = @"ChannelVideoPlayerLayerObserverContext";

// KVO player keys
static NSString * const ChannelVideoPlayerControllerTracksKey = @"tracks";
static NSString * const ChannelVideoPlayerControllerPlayableKey = @"playable";
static NSString * const ChannelVideoPlayerControllerDurationKey = @"duration";
static NSString * const ChannelVideoPlayerControllerRateKey = @"rate";

// KVO player item keys
static NSString * const ChannelVideoPlayerControllerStatusKey = @"status";
static NSString * const ChannelVideoPlayerControllerEmptyBufferKey = @"playbackBufferEmpty";
static NSString * const ChannelVideoPlayerControllerPlayerKeepUpKey = @"playbackLikelyToKeepUp";

// KVO player layer keys
static NSString * const ChannelVideoPlayerControllerReadyForDisplay = @"readyForDisplay";

// TODO: scrubbing support
//static float const ChannelVideoPlayerControllerRates[ChannelVideoPlayerRateCount] = { 0.25, 0.5, 0.75, 1, 1.5, 2 };
//static NSInteger const ChannelVideoPlayerRateCount = 6;

@interface ChannelVideoPlayerController () <UIGestureRecognizerDelegate>
{
    AVAsset *_asset;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    
    NSString *_videoPath;
    PBJVideoView *_videoView;
    
    ChannelVideoPlayerPlaybackState _playbackState;
    ChannelVideoPlayerBufferingState _bufferingState;
    
    // flags
    struct {
        unsigned int playbackLoops:1;
        unsigned int playbackFreezesAtEnd:1;
    } __block _flags;
    
    float _volume;
}

@end

@implementation ChannelVideoPlayerController

@synthesize delegate = _delegate;
@synthesize videoPath = _videoPath;
@synthesize playbackState = _playbackState;
@synthesize bufferingState = _bufferingState;
@synthesize videoFillMode = _videoFillMode;

#pragma mark - getters/setters

- (void)setVideoFillMode:(NSString *)videoFillMode
{
    if (_videoFillMode != videoFillMode) {
        _videoFillMode = videoFillMode;
        _videoView.videoFillMode = _videoFillMode;
    }
}

- (NSString *)videoPath
{
    return _videoPath;
}

- (void)setVideoPath:(NSString *)videoPath
{
    if (!videoPath || [videoPath length] == 0)
        return;
    
    NSURL *videoURL = [NSURL URLWithString:videoPath];
    if (!videoURL || ![videoURL scheme]) {
        videoURL = [NSURL fileURLWithPath:videoPath];
    }
    _videoPath = [videoPath copy];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    [self setAsset:asset];
}

- (void)setAsset:(AVAsset *)asset {
    [self _setAsset:asset];
}

- (AVAsset *)asset {
    return _asset;
}

- (BOOL)playbackLoops
{
    return _flags.playbackLoops;
}

- (void)setPlaybackLoops:(BOOL)playbackLoops
{
    _flags.playbackLoops = (unsigned int)playbackLoops;
    if (!_player)
        return;
    
    if (!_flags.playbackLoops) {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
}

- (BOOL)playbackFreezesAtEnd
{
    return _flags.playbackFreezesAtEnd;
}

- (void)setPlaybackFreezesAtEnd:(BOOL)playbackFreezesAtEnd
{
    _flags.playbackFreezesAtEnd = (unsigned int)playbackFreezesAtEnd;
}

- (NSTimeInterval)maxDuration {
    NSTimeInterval maxDuration = -1;
    
    if (CMTIME_IS_NUMERIC(_playerItem.duration)) {
        maxDuration = CMTimeGetSeconds(_playerItem.duration);
    }
    
    return maxDuration;
}

- (float)volume {
    return _player.volume;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    
    if (!_player) {
        return;
    }
    
    _player.volume = volume;
}

- (void)_setAsset:(AVAsset *)asset
{
    if (_asset == asset) {
        return;
    }
    
    if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying) {
        [self pause];
    }
    
    _bufferingState = ChannelVideoPlayerBufferingStateUnknown;
    if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]){
        [_delegate videoPlayerBufferringStateDidChange:self];
    }
    
    _asset = asset;
    
    if (!_asset) {
        [self _setPlayerItem:nil];
    }
    
    NSArray *keys = @[ChannelVideoPlayerControllerTracksKey, ChannelVideoPlayerControllerPlayableKey, ChannelVideoPlayerControllerDurationKey];
    
    [_asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        [self _enqueueBlockOnMainQueue:^{
            
            // check the keys
            for (NSString *key in keys) {
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                if (keyStatus == AVKeyValueStatusFailed) {
                    _playbackState = ChannelVideoPlayerPlaybackStateFailed;
                    [_delegate videoPlayerPlaybackStateDidChange:self];
                    return;
                }
            }
            
            // check playable
            if (!_asset.playable) {
                _playbackState = ChannelVideoPlayerPlaybackStateFailed;
                [_delegate videoPlayerPlaybackStateDidChange:self];
                return;
            }
            
            // setup player
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_asset];
            [self _setPlayerItem:playerItem];
            
        }];
    }];
}

- (void)_setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem)
        return;
    
    // remove observers
    if (_playerItem) {
        // AVPlayerItem KVO
        [_playerItem removeObserver:self forKeyPath:ChannelVideoPlayerControllerEmptyBufferKey context:(__bridge void *)(ChannelVideoPlayerItemObserverContext)];
        [_playerItem removeObserver:self forKeyPath:ChannelVideoPlayerControllerPlayerKeepUpKey context:(__bridge void *)(ChannelVideoPlayerItemObserverContext)];
        [_playerItem removeObserver:self forKeyPath:ChannelVideoPlayerControllerStatusKey context:(__bridge void *)(ChannelVideoPlayerItemObserverContext)];
        
        // notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    }
    
    _playerItem = playerItem;
    
    // add observers
    if (_playerItem) {
        // AVPlayerItem KVO
        [_playerItem addObserver:self forKeyPath:ChannelVideoPlayerControllerEmptyBufferKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ChannelVideoPlayerItemObserverContext)];
        [_playerItem addObserver:self forKeyPath:ChannelVideoPlayerControllerPlayerKeepUpKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ChannelVideoPlayerItemObserverContext)];
        [_playerItem addObserver:self forKeyPath:ChannelVideoPlayerControllerStatusKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ChannelVideoPlayerItemObserverContext)];
        
        // notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    }
    
    if (!_flags.playbackLoops) {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
}

#pragma mark - init

- (void)dealloc
{
    _videoView.player = nil;
    _delegate = nil;
    
    // notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Layer KVO
    [_videoView.layer removeObserver:self forKeyPath:ChannelVideoPlayerControllerReadyForDisplay context:(__bridge void *)ChannelVideoPlayerLayerObserverContext];
    
    // AVPlayer KVO
    [_player removeObserver:self forKeyPath:ChannelVideoPlayerControllerRateKey context:(__bridge void *)ChannelVideoPlayerObserverContext];
    
    // player
    [_player pause];
    
    // player item
    [self _setPlayerItem:nil];
}

#pragma mark - view lifecycle

- (void)loadView
{
    _player = [[AVPlayer alloc] init];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    // Player KVO
    [_player addObserver:self forKeyPath:ChannelVideoPlayerControllerRateKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ChannelVideoPlayerObserverContext)];
    
    // load the playerLayer view
    _videoView = [[PBJVideoView alloc] initWithFrame:CGRectZero];
    _videoView.videoFillMode = AVLayerVideoGravityResizeAspect;
    _videoView.playerLayer.hidden = YES;
    self.view = _videoView;
    
    // playerLayer KVO
    [_videoView.playerLayer addObserver:self forKeyPath:ChannelVideoPlayerControllerReadyForDisplay options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(ChannelVideoPlayerLayerObserverContext)];
    
    // Application NSNotifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(_applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying)
        [self pause];
}

#pragma mark - private methods

- (void)_videoPlayerAudioSessionActive:(BOOL)active
{
    NSString *category = active ? AVAudioSessionCategoryPlayback : AVAudioSessionCategoryAmbient;
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:category error:&error];
    if (error) {
        POLYLog(@"audio session active error (%@)", error);
    }
}

- (void)_updatePlayerRatio
{
}

#pragma mark - public methods

- (void)playFromBeginning
{
    POLYLog(@"playing from beginnging...");
    
    [_delegate videoPlayerPlaybackWillStartFromBeginning:self];
    [_player seekToTime:kCMTimeZero];
    [self playFromCurrentTime];
}

- (void)playFromCurrentTime
{
    POLYLog(@"playing...");
    
    _playbackState = ChannelVideoPlayerPlaybackStatePlaying;
    [_delegate videoPlayerPlaybackStateDidChange:self];
    [_player play];
}

- (void)pause
{
    if (_playbackState != ChannelVideoPlayerPlaybackStatePlaying)
        return;
    
    POLYLog(@"pause");
    
    [_player pause];
    _playbackState = ChannelVideoPlayerPlaybackStatePaused;
    [_delegate videoPlayerPlaybackStateDidChange:self];
}

- (void)stop
{
    if (_playbackState == ChannelVideoPlayerPlaybackStateStopped)
        return;
    
    POLYLog(@"stop");
    
    [_player pause];
    _playbackState = ChannelVideoPlayerPlaybackStateStopped;
    [_delegate videoPlayerPlaybackStateDidChange:self];
}

#pragma mark - main queue helper

typedef void (^ChannelVideoPlayerBlock)();

- (void)_enqueueBlockOnMainQueue:(ChannelVideoPlayerBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

#pragma mark - UIResponder

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_videoPath || _asset) {
        
        switch (_playbackState) {
            case ChannelVideoPlayerPlaybackStateStopped:
            {
                [self playFromBeginning];
                break;
            }
            case ChannelVideoPlayerPlaybackStatePaused:
            {
                [self playFromCurrentTime];
                break;
            }
            case ChannelVideoPlayerPlaybackStatePlaying:
            case ChannelVideoPlayerPlaybackStateFailed:
            default:
            {
                [self pause];
                break;
            }
        }
        
    } else {
        [super touchesEnded:touches withEvent:event];
    }
    
}

- (void)_handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying) {
        [self pause];
    } else if (_playbackState == ChannelVideoPlayerPlaybackStateStopped) {
        [self playFromBeginning];
    } else {
        [self playFromCurrentTime];
    }
}

#pragma mark - AV NSNotificaions

- (void)_playerItemDidPlayToEndTime:(NSNotification *)aNotification
{
    if (_flags.playbackLoops || !_flags.playbackFreezesAtEnd) {
        [_player seekToTime:kCMTimeZero];
    }
    
    if (!_flags.playbackLoops) {
        [self stop];
        [_delegate videoPlayerPlaybackDidEnd:self];
    }
}

- (void)_playerItemFailedToPlayToEndTime:(NSNotification *)aNotification
{
    _playbackState = ChannelVideoPlayerPlaybackStateFailed;
    [_delegate videoPlayerPlaybackStateDidChange:self];
    POLYLog(@"error (%@)", [[aNotification userInfo] objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey]);
}

#pragma mark - App NSNotifications

- (void)_applicationWillResignActive:(NSNotification *)aNotfication
{
    if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying)
        [self pause];
}

- (void)_applicationDidEnterBackground:(NSNotification *)aNotfication
{
    if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying)
        [self pause];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(ChannelVideoPlayerObserverContext) ) {
        
        // Player KVO
        
    } else if ( context == (__bridge void *)(ChannelVideoPlayerItemObserverContext) ) {
        
        // PlayerItem KVO
        
        if ([keyPath isEqualToString:ChannelVideoPlayerControllerEmptyBufferKey]) {
            if (_playerItem.playbackBufferEmpty) {
                _bufferingState = ChannelVideoPlayerBufferingStateDelayed;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                POLYLog(@"playback buffer is empty");
            }
        } else if ([keyPath isEqualToString:ChannelVideoPlayerControllerPlayerKeepUpKey]) {
            if (_playerItem.playbackLikelyToKeepUp) {
                _bufferingState = ChannelVideoPlayerBufferingStateReady;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                POLYLog(@"playback buffer is likely to keep up");
                if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying) {
                    [self playFromCurrentTime];
                }
            }
        }
        
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusReadyToPlay:
            {
                _videoView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
                [_videoView.playerLayer setPlayer:_player];
                _videoView.playerLayer.hidden = NO;
                break;
            }
            case AVPlayerStatusFailed:
            {
                _playbackState = ChannelVideoPlayerPlaybackStateFailed;
                [_delegate videoPlayerPlaybackStateDidChange:self];
                break;
            }
            case AVPlayerStatusUnknown:
            default:
                break;
        }
        
    } else if ( context == (__bridge void *)(ChannelVideoPlayerLayerObserverContext) ) {
        
        // PlayerLayer KVO
        
        if ([keyPath isEqualToString:ChannelVideoPlayerControllerReadyForDisplay]) {
            if (_videoView.playerLayer.readyForDisplay) {
                [_delegate videoPlayerReady:self];
            }
        }
        
    } else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        
    }
}

@end
