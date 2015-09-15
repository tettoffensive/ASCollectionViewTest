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
@import FXBlurView;
@import PBJVideoPlayer;
@import AVFoundation;
@import KVOController;
@import SDWebImage;

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
    AVQueuePlayer *_player;
    
    PBJVideoView *_videoView;
    UIImageView  *_thumbnailImageView;

    ChannelVideoPlayerPlaybackState _playbackState;
    ChannelVideoPlayerBufferingState _bufferingState;
    
    // flags
    struct {
        unsigned int playbackLoops:1;
        unsigned int playbackFreezesAtEnd:1;
    } __block _flags;
    
    float _volume;
}

@property (nonatomic) CGFloat unmuteVolume;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic) BOOL forcedStop;

@end

@implementation ChannelVideoPlayerController

@synthesize delegate = _delegate;
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

- (void)mute
{
    if (self.isMuted) {
        return;
    }
    
    _muted = YES;
    self.unmuteVolume = self.volume;
    [self setVolume:0];
}

- (void)unmute
{
    if (! self.isMuted) {
        return;
    }
    
    _muted = NO;
    [self setVolume:self.unmuteVolume];
}

- (CGFloat)volume
{
    return _player.volume;
}

- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    
    if (!_player) {
        return;
    }
    
    _player.volume = volume;
}

#pragma mark - init

- (void)dealloc
{
    _videoView.player = nil;
    _delegate = nil;
    
    // notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_player pause];
    [self.KVOController unobserveAll];
}

#pragma mark - view lifecycle

- (void)loadView
{
    _player = [[AVQueuePlayer alloc] init];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    [self.KVOController observe:_player
                        keyPath:ChannelVideoPlayerControllerRateKey
                        options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                        context:(__bridge void *)(ChannelVideoPlayerObserverContext)];
    
    // load the playerLayer view
    _videoView = [[PBJVideoView alloc] initWithFrame:CGRectZero];
    _videoView.videoFillMode = AVLayerVideoGravityResizeAspect;
    _videoView.playerLayer.hidden = NO;
    self.view = _videoView;
    
    // playerLayer KVO
    [self.KVOController observe:_videoView.playerLayer
                        keyPath:ChannelVideoPlayerControllerReadyForDisplay
                        options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                          context:(__bridge void *)(ChannelVideoPlayerLayerObserverContext)];
    
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

#pragma mark - public methods

- (void)playMediaAtIndex:(NSUInteger)index
{
    if (!self.dataSource ||
        [self.dataSource numberOfPlayerItems] < 1) {
        return;
    }
    [self willChangeValueForKey:@"currentItemIndex"];
    _currentItemIndex = index;
    [self didChangeValueForKey:@"currentItemIndex"];
    
    [self playCurrentMedia];
}

 - (void)next
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerWillPlayNextItem)]) {
        [self.delegate videoPlayerWillPlayNextItem];
    }
    
    [self willChangeValueForKey:@"currentItemIndex"];
    if ([self.dataSource numberOfPlayerItems] > 0) {
        _currentItemIndex = (_currentItemIndex+1) % [self.dataSource numberOfPlayerItems];
    } else {
        _currentItemIndex = 0;
    }
    [self didChangeValueForKey:@"currentItemIndex"];
    [self playCurrentMedia];
}

- (void)previous
{
    [self willChangeValueForKey:@"currentItemIndex"];
    if ([self.dataSource numberOfPlayerItems] > 0) {
        _currentItemIndex = (_currentItemIndex < 1) ? [self.dataSource numberOfPlayerItems]-1 : _currentItemIndex-1;
    } else {
        _currentItemIndex = 0;
    }
    [self didChangeValueForKey:@"currentItemIndex"];
    [self playCurrentMedia];
}

- (void)playCurrentMedia
{
    if (_currentItemIndex > [self.dataSource numberOfPlayerItems] - 1) {
        [self willChangeValueForKey:@"currentItemIndex"];
        _currentItemIndex = 0;
        [self didChangeValueForKey:@"currentItemIndex"];
    }
    
    NSURL *mediaURL = [self.dataSource videoPlayer:self playerItemAtIndex:_currentItemIndex];
    
    AVPlayerItem *nextItemInQueue = nil;
    if (_player.items.count > 1) {
        nextItemInQueue = _player.items[1];
        if ([nextItemInQueue.asset respondsToSelector:@selector(URL)]) {
            if (![mediaURL.absoluteString isEqualToString:[(id)nextItemInQueue.asset URL].absoluteString]) {
                nextItemInQueue = nil;
            }
        }
    }
    
    AVPlayerItem *playerItem = (nextItemInQueue) ? nextItemInQueue : [AVPlayerItem playerItemWithURL:mediaURL];
    
    UIImageView *currentMediaImageView = [self imageViewForMediaAtIndex:_currentItemIndex];
    [currentMediaImageView setAlpha:0];
    [_videoView addSubview:currentMediaImageView];
    [_videoView bringSubviewToFront:currentMediaImageView];
    [_thumbnailImageView removeFromSuperview];
    _thumbnailImageView = currentMediaImageView;
    
    BOOL shouldReplace = (playerItem != nextItemInQueue);

    if (playerItem.status != AVPlayerItemStatusReadyToPlay) {
        [UIView animateWithDuration:0.35 animations:^{
            [currentMediaImageView setAlpha:1];
        } completion:^(BOOL finished) {
            if (finished) {
                [self commitAdvanceWith:playerItem replace:shouldReplace];
            }
        }];
    } else {
        [self commitAdvanceWith:playerItem replace:shouldReplace];
    }
}

- (void)commitAdvanceWith:(AVPlayerItem *)playerItem replace:(BOOL)shouldReplace
{
    [self.KVOController observe:playerItem
                       keyPaths:@[ChannelVideoPlayerControllerStatusKey,ChannelVideoPlayerControllerPlayerKeepUpKey,ChannelVideoPlayerControllerEmptyBufferKey]
                        options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                        context:(__bridge void *)(ChannelVideoPlayerItemObserverContext)];
    
    self.currentItem = playerItem;
    
    [self pause];
    
    if (shouldReplace) {
        [_player removeAllItems];
        [_player replaceCurrentItemWithPlayerItem:self.currentItem];
    } else {
        [_player advanceToNextItem];
    }
    
    [self preloadNextMedia];
}

- (void)preloadNextMedia
{
    if ([self.dataSource numberOfPlayerItems] <= 0) {
        return;
    }
    
    NSUInteger index = (_currentItemIndex+1) % [self.dataSource numberOfPlayerItems];
    
    if (index == _currentItemIndex) {
        // only 1 item, no next media
        return;
    }
    
    NSURL *mediaURL = [self.dataSource videoPlayer:self playerItemAtIndex:index];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:mediaURL];
    [self imageViewForMediaAtIndex:index]; // start downloading to cache
    [_player insertItem:playerItem afterItem:nil];
}

- (void)playFromBeginning
{
    POLYLog(@"playing from beginnging...");
    
    [_delegate videoPlayerPlaybackWillStartFromBeginning:self];
    [_player seekToTime:kCMTimeZero];
    [self resume];
}

- (void)resume
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

-(void)setCurrentItem:(AVPlayerItem *)currentItem
{
    if (!currentItem && _currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_currentItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                      object:_currentItem];
    }
    
    _currentItem = currentItem;
    
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerItemDidPlayToEndTime:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerItemFailedToPlayToEndTime:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                   object:_currentItem];
    }
}

-(UIImageView*)imageViewForMediaAtIndex:(NSUInteger)index
{
    NSURL *thumbnailURL = [self.dataSource videoPlayer:self thumbnailItemAtIndex:index];
    UIImageView *imageView = [UIImageView new];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setFrame:_videoView.frame];
//    [imageView setHeight:imageView.height*0.5];
//    [imageView setWidth:imageView.width*0.5];
    FXBlurView *blurEffect = [[FXBlurView alloc] initWithFrame:imageView.frame];
    blurEffect.dynamic = NO; // change if ever over a video
    blurEffect.tintColor = [UIColor clearColor];
    blurEffect.blurRadius = 7.;
    blurEffect.updateInterval = 1;
    [imageView addSubview:blurEffect];
    [blurEffect setAlpha:1];
    [imageView sd_setImageWithURL:thumbnailURL placeholderImage:[UIImage imageNamed:@"Truffle Bucket"]];
    imageView.hidden = YES; // RYAN_TODO: Thumbnails were causing a series of flashes
    return imageView;
}

#pragma mark - UIResponder

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (_playbackState) {
        case ChannelVideoPlayerPlaybackStateStopped: {
            [self playFromBeginning];
            break;
        }
        case ChannelVideoPlayerPlaybackStatePaused: {
            [self resume];
            break;
        }
        case ChannelVideoPlayerPlaybackStatePlaying:
        case ChannelVideoPlayerPlaybackStateFailed:
        default: {
            [self pause];
            break;
        }
    }
}

- (void)_handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying) {
        [self pause];
    } else if (_playbackState == ChannelVideoPlayerPlaybackStateStopped) {
        [self playFromBeginning];
    } else {
        [self resume];
    }
}

#pragma mark - AV NSNotificaions

- (void)_playerItemDidPlayToEndTime:(NSNotification *)aNotification
{
    self.forcedStop = NO;
    [_delegate videoPlayerPlaybackDidEnd:self];
    [self next];
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
        
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        
        if ([keyPath isEqualToString:ChannelVideoPlayerControllerEmptyBufferKey]) {
            if (self.currentItem.playbackBufferEmpty) {
                _bufferingState = ChannelVideoPlayerBufferingStateDelayed;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                POLYLog(@"playback buffer is empty");
                [_thumbnailImageView.layer removeAllAnimations];
                [UIView animateWithDuration:0.15 animations:^{
                    [_thumbnailImageView setAlpha:1];
                }];
            }
        } else if ([keyPath isEqualToString:ChannelVideoPlayerControllerPlayerKeepUpKey]) {
            if (self.currentItem.playbackLikelyToKeepUp) {
                _bufferingState = ChannelVideoPlayerBufferingStateReady;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                POLYLog(@"playback buffer is likely to keep up");
                if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying && status == AVPlayerStatusReadyToPlay) {
                    if (_videoView.playerLayer.readyForDisplay) {
                        [_thumbnailImageView.layer removeAllAnimations];
                        [UIView animateWithDuration:0.35 animations:^{
                            [_thumbnailImageView setAlpha:0];
                        }];
                    }
                    [self resume];
                }
            }
        }
        
        switch (status) {
            case AVPlayerStatusReadyToPlay: {
                _videoView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
                if (_videoView.playerLayer.player != _player) {
                    [_videoView.playerLayer setPlayer:_player];
                }
                _videoView.playerLayer.hidden = NO;
                if (self.playbackState != ChannelVideoPlayerPlaybackStatePlaying && _player.currentItem.playbackLikelyToKeepUp) {
                    if (_videoView.playerLayer.readyForDisplay) {
                        [_thumbnailImageView.layer removeAllAnimations];
                        [UIView animateWithDuration:0.35 animations:^{
                            [_thumbnailImageView setAlpha:0];
                        }];
                    }
                    [self playFromBeginning];
                } else {
                    _playbackState = ChannelVideoPlayerPlaybackStatePlaying; // should start playing when likely to keep up
                }
                break;
            }
            case AVPlayerStatusFailed: {
                _playbackState = ChannelVideoPlayerPlaybackStateFailed;
                [_thumbnailImageView.layer removeAllAnimations];
                [UIView animateWithDuration:0.15 animations:^{
                    [_thumbnailImageView setAlpha:1];
                }];
                [self pause];
                break;
            }
            case AVPlayerStatusUnknown:
            default:
                [_thumbnailImageView.layer removeAllAnimations];
                [UIView animateWithDuration:0.15 animations:^{
                    [_thumbnailImageView setAlpha:1];
                }];
                [self pause];
                break;
        }
        
    } else if ( context == (__bridge void *)(ChannelVideoPlayerLayerObserverContext) ) {
        
        // PlayerLayer KVO
        
        if ([keyPath isEqualToString:ChannelVideoPlayerControllerReadyForDisplay]) {
            if (_videoView.playerLayer.readyForDisplay) {
                [_delegate videoPlayerReady:self];
                
                if (_playbackState == ChannelVideoPlayerPlaybackStatePlaying && _player.status == AVPlayerStatusReadyToPlay && _player.currentItem.playbackLikelyToKeepUp) {
                    [_thumbnailImageView.layer removeAllAnimations];
                    [UIView animateWithDuration:0.35 animations:^{
                        [_thumbnailImageView setAlpha:0];
                    }];
                }
            }
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
