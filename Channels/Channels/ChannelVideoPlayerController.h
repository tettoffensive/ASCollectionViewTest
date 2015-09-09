//
//  ChannelVideoPlayerController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//
//  Modified from: PBJVideoPlayerController.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, ChannelVideoPlayerPlaybackState) {
    ChannelVideoPlayerPlaybackStateStopped = 0,
    ChannelVideoPlayerPlaybackStatePlaying,
    ChannelVideoPlayerPlaybackStatePaused,
    ChannelVideoPlayerPlaybackStateFailed,
};

typedef NS_ENUM(NSInteger, ChannelVideoPlayerBufferingState) {
    ChannelVideoPlayerBufferingStateUnknown = 0,
    ChannelVideoPlayerBufferingStateReady,
    ChannelVideoPlayerBufferingStateDelayed,
};

// ChannelVideoPlayerController.view provides the interface for playing/streaming videos
@protocol ChannelVideoPlayerControllerDelegate, ChannelVideoPlayerControllerDataSource;

@interface ChannelVideoPlayerController : UIViewController

@property (nonatomic, weak) id<ChannelVideoPlayerControllerDelegate> delegate;
@property (nonatomic, weak) id<ChannelVideoPlayerControllerDataSource> dataSource;

@property (nonatomic, copy, setter=setVideoFillMode:) NSString *videoFillMode; // default, AVLayerVideoGravityResizeAspect

@property (nonatomic) BOOL playbackLoops;
@property (nonatomic) BOOL playbackFreezesAtEnd;
@property (nonatomic, readonly) ChannelVideoPlayerPlaybackState playbackState;
@property (nonatomic, readonly) ChannelVideoPlayerBufferingState bufferingState;
@property (nonatomic) CGFloat volume;
@property (nonatomic, readonly, getter = isMuted) BOOL muted;
@property (nonatomic, readonly) NSUInteger currentItemIndex;

- (void)playCurrentMedia;
- (void)playFromBeginning;
- (void)playMediaAtIndex:(NSUInteger)index;
- (void)resume;
- (void)pause;
- (void)stop;
- (void)next;
- (void)previous;
- (void)mute;
- (void)unmute;

@end

@protocol ChannelVideoPlayerControllerDataSource <NSObject>

@required
- (NSUInteger)numberOfPlayerItems;
- (NSURL *)videoPlayer:(ChannelVideoPlayerController *)player playerItemAtIndex:(NSInteger)index;

@end

@protocol ChannelVideoPlayerControllerDelegate <NSObject>
@required
- (void)videoPlayerReady:(ChannelVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackStateDidChange:(ChannelVideoPlayerController *)videoPlayer;

- (void)videoPlayerPlaybackWillStartFromBeginning:(ChannelVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackDidEnd:(ChannelVideoPlayerController *)videoPlayer;

@optional
- (void)videoPlayerBufferringStateDidChange:(ChannelVideoPlayerController *)videoPlayer;

@end
