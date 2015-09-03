//
//  ChannelRecordVideoButton.m
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelRecordVideoButton.h"
#import <POP/POP.h>

@interface ChannelRecordVideoButton ()
{
    UIView *_recordVideoButton;
    UIView *_recordVideoButtonStatusView;
}

@end

@implementation ChannelRecordVideoButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _recordVideoButton = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 70.0f, 70.0f)];
        [_recordVideoButton setBackgroundColor:[UIColor whiteColor]];
        [_recordVideoButton setCenter:self.center];
        _recordVideoButton.layer.cornerRadius = _recordVideoButton.frame.size.width / 2.0;
        _recordVideoButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _recordVideoButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        _recordVideoButton.layer.shadowOpacity = 0.25f;
        _recordVideoButton.layer.shadowRadius = 1.0f;
        [self addSubview:_recordVideoButton];
        
        
        _recordVideoButtonStatusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        [_recordVideoButtonStatusView setUserInteractionEnabled:NO];
        [_recordVideoButtonStatusView setBackgroundColor:[UIColor redColor]];
        _recordVideoButtonStatusView.layer.cornerRadius = _recordVideoButtonStatusView.frame.size.width / 2.0;
        [_recordVideoButtonStatusView setCenter:CGPointMake(_recordVideoButton.frame.size.width / 2.0, _recordVideoButton.frame.size.height / 2.0)];
        [_recordVideoButton addSubview:_recordVideoButtonStatusView];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self animateRecordStatusButton:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self animateRecordStatusButton:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self animateRecordStatusButton:NO];
}

- (void)animateRecordStatusButton:(BOOL)start
{
    CGFloat scale = 61.0 / 24.0;
    CGSize size = start ? CGSizeMake(scale, scale) : CGSizeMake(1.0f, 1.0f);
    
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:size];
    scaleAnimation.duration = 0.25f;
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (start)
            [self.delegate didStartRecording];
        else
            [self.delegate didEndRecording];
    };
    [_recordVideoButtonStatusView pop_addAnimation:scaleAnimation forKey:@"scaleAnim"];
}

- (void)stopRecording
{
    [self animateRecordStatusButton:NO];
}

@end
