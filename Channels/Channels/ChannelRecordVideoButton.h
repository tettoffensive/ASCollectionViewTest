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

@end

@interface ChannelRecordVideoButton : UIView

@property (nonatomic, assign) id <ChannelRecordVideoButtonDelegate> delegate;

- (void)stopRecording;

@end
