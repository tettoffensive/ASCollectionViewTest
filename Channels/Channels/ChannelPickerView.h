//
//  ChannelPickerView.h
//  Channels
//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChannelModel;

@protocol ChannelPickerViewDelegate

- (void)createChannel;
- (void)postVideoToChannel:(ChannelModel *)channel;

@end

@interface ChannelPickerView : UIView

@property (nonatomic, assign) id <ChannelPickerViewDelegate> delegate;

@end
