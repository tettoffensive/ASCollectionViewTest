//
//  ChannelRecordVideoButton.m
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelRecordVideoButton.h"
#import <POP/POP.h>

/** Degrees to Radian **/
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
/** Radians to Degrees **/
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

@interface ChannelRecordVideoButton ()
{
    UIView *_recordVideoButton;
    UIView *_recordVideoButtonStatusView;
    
    CGFloat _startAngle;
    CGFloat _endAngle;
    CGFloat _percent;
    
    NSTimer *_progressTimer;
}

@end

@implementation ChannelRecordVideoButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.maxVideoDuration = 0.0f;
        
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
        
        // Set start and end angles and starting percent
        _startAngle = M_PI * 1.5;
        _endAngle = _startAngle + (M_PI * 2);
        _percent = 0.0f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if ([self hasMaxVideoLength]) {
        UIBezierPath *bezierPathShadow = [UIBezierPath bezierPath];
        
        [bezierPathShadow addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                                    radius:42.0f
                                startAngle:_startAngle - degreesToRadians(1.0f)
                                  endAngle:(_endAngle - _startAngle) * (_percent / 100.0) + _startAngle + degreesToRadians(1.0f)
                                 clockwise:YES];
        
        bezierPathShadow.lineWidth = 6.0f;
        [[UIColor colorWithWhite:0.0f alpha:0.05f] setStroke];
        [bezierPathShadow stroke];
        
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        
        [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                              radius:52.0f
                          startAngle:_startAngle
                            endAngle:(_endAngle - _startAngle) * (_percent / 100.0) + _startAngle
                           clockwise:YES];
        
        bezierPath.lineWidth = 6.0f;
//        [[UIColor colorWithWhite:1.0f alpha:0.75f] setStroke];
        [[UIColor redColor] setStroke];
        [bezierPath stroke];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self startRecording];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self stopRecording];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self stopRecording];
}

- (void)incrementSpin
{
    if (_percent >= 0 && _percent < 100) {
        _percent += [self incrementInterval];
        [self setNeedsDisplay];
    }
}

- (void)animateRecordStatusButton:(BOOL)start
{
    if (start) {
        [self.delegate didStartRecording];
    }
    
    CGFloat scale = 60.0 / 24.0;
    CGSize size = start ? CGSizeMake(scale, scale) : CGSizeMake(1.0f, 1.0f);
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:size];
    scaleAnimation.duration = 0.25f;
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (!start) {
            [self resetProgressView];
            [self.delegate didEndRecording];
        }
    };
    [_recordVideoButtonStatusView pop_addAnimation:scaleAnimation forKey:@"scaleAnim"];
    
    
    CGFloat scale2 = 84.0 / 70.0;
    CGSize size2 = start ? CGSizeMake(scale2, scale2) : CGSizeMake(1.0f, 1.0f);
    POPBasicAnimation *scaleAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation2.toValue = [NSValue valueWithCGSize:size2];
    scaleAnimation2.duration = 0.25f;
    [_recordVideoButton pop_addAnimation:scaleAnimation2 forKey:@"scaleAnim"];
}

- (void)startRecording
{
    [self animateRecordStatusButton:YES];
    
    if ([self hasMaxVideoLength]) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:[self timerInterval]
                                                          target:self
                                                        selector:@selector(incrementSpin)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)stopRecording
{
    if ([self.delegate videoHasMinimumLength]) {
        if ([self.delegate checkIfVideoHasReachedMinimumLength]) {
            [self animateRecordStatusButton:NO];
        } else {
            [self.delegate didEndRecording];
        }
    } else {
        [self animateRecordStatusButton:NO];
    }
}

- (void)resetProgressView
{
    _percent = 0.0f;
    [self setNeedsDisplay];
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (CGFloat)timerPrecision
{
    // Increase this to make circular progress view smooth
    return 4.0f;
}

- (CGFloat)timerInterval
{
    return self.maxVideoDuration / 100.0f / [self timerPrecision];
}

- (CGFloat)incrementInterval
{
    return 1.0f / [self timerPrecision];
}

- (BOOL)hasMaxVideoLength
{
    return self.maxVideoDuration > 0.0f ? YES : NO;
}

@end