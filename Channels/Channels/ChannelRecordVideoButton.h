//
//  ChannelRecordVideoButton.h
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChannelRecordVideoButtonDelegate

@required
- (void)didStartRecording;
- (void)didEndRecording;

@optional
- (BOOL)videoHasMinimumLength;
- (BOOL)checkIfVideoHasReachedMinimumLength;

@end

@interface ChannelRecordVideoButton : UIView

@property (nonatomic, assign) id <ChannelRecordVideoButtonDelegate> delegate;
@property (nonatomic, assign) CGFloat maxVideoDuration;

- (void)stopRecording;

@end
