//
//  POLYActivityIndicator.m
//  loading
//
//  Created by Dana Shakiba on 9/8/15.
//  Copyright © 2015 swipe. All rights reserved.
//

#import "POLYActivityIndicator.h"
#import <POP/POP.h>

@interface POLYActivityIndicator()

@property (nonatomic, strong) UIImageView *spinningImageView;
@property (nonatomic, strong) UIView *completionView;

@end

@implementation POLYActivityIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        _spinningImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spinning Indicator"]];
        [_spinningImageView setCenter:self.center];
        [_spinningImageView setAlpha:0.0f];
        [self addSubview:_spinningImageView];
        
        _completionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [_completionView setBackgroundColor:[UIColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:113.0/255.0 alpha:1.0]];
        [_completionView.layer setCornerRadius:_completionView.bounds.size.width/2.0f];
        [_completionView setCenter:self.center];
        [_completionView setAlpha:0.0f];
        
        [self addSubview:_completionView];
    }
    return self;
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Animations
#pragma -------------------------------------------------------------------------------------------

- (void)start
{
    // Spinning Icon
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnimation.fromValue = @(0.0f);
    alphaAnimation.toValue = @(1.0f);
    [_spinningImageView pop_addAnimation:alphaAnimation forKey:@"alphaAnim"];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    [_spinningImageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnim"];
    
    POPBasicAnimation *rotateAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateAnimation.toValue = @(2*M_PI);
    rotateAnimation.duration = 1.0f;
    rotateAnimation.repeatForever = YES;
    [_spinningImageView.layer pop_addAnimation:rotateAnimation forKey:@"rotateAnim"];
}

- (void)stopWithCompletion:(BOOL)showCompletion
{
    // Spinning Icon
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.0f);
    [_spinningImageView pop_addAnimation:alphaAnimation forKey:@"alphaAnim"];
    
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)];
    [_spinningImageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnim"];
    
    // Completion Icon
    if (showCompletion) {
        // Spinning Icon
        POPBasicAnimation *alphaAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation2.fromValue = @(0.0f);
        alphaAnimation2.toValue = @(1.0f);
        alphaAnimation.duration = 0.1f;
        [_completionView pop_addAnimation:alphaAnimation2 forKey:@"alphaAnim"];
        
        POPBasicAnimation *scaleAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation2.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)];
        scaleAnimation2.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
        scaleAnimation.duration = 0.5f;
        scaleAnimation2.completionBlock = ^void(POPAnimation *anim, BOOL finished) {
            [self drawBezierAnimate:YES];
        };
        [_completionView.layer pop_addAnimation:scaleAnimation2 forKey:@"scaleAnim"];
    }
}

- (void)completeAnimation
{
    POPBasicAnimation *scaleAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnim.fromValue = [NSValue valueWithCGSize:CGSizeMake(!.0f, 1.0f)];
    scaleAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)];
    scaleAnim.duration = 0.5f;
    scaleAnim.completionBlock = ^void(POPAnimation *anim, BOOL finished) {
        [self removeFromSuperview];
    };
    [_completionView.layer pop_addAnimation:scaleAnim forKey:@"scaleAnim"];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Bezier Path Creation
#pragma -------------------------------------------------------------------------------------------

- (UIBezierPath *)bezierPath
{
    CGRect frame = self.bounds;
    
    UIBezierPath* shape5Path = UIBezierPath.bezierPath;
    
    [shape5Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.35227 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48296 * CGRectGetHeight(frame))];
    [shape5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46950 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60227 * CGRectGetHeight(frame))];
    [shape5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67045 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39773 * CGRectGetHeight(frame))];
    
    return shape5Path;
}

- (void)drawBezierAnimate:(BOOL)animate
{
    UIBezierPath *bezierPath = [self bezierPath];
    BOOL reverse = NO;
    if (reverse) {
        bezierPath = [bezierPath bezierPathByReversingPath];
    }
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path          = bezierPath.CGPath;
    shapeLayer.strokeColor   = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor     = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth     = 3.0;
    shapeLayer.strokeStart   = 0.0;
    shapeLayer.strokeEnd     = 1.0;
    shapeLayer.miterLimit    = 100.0;
    shapeLayer.lineCap       = kCALineCapRound;
    shapeLayer.lineJoin      = kCALineJoinRound;
    [self.layer addSublayer:shapeLayer];
    
    if (animate) {
        // kPOPShapeLayerStrokeStart, kPOPShapeLayerStrokeEnd
        POPSpringAnimation *strokeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
        strokeAnimation.fromValue = @(0.0f);
        strokeAnimation.toValue = @(1.0f);
        strokeAnimation.dynamicsFriction = 20;
        strokeAnimation.dynamicsMass = 1;
        strokeAnimation.dynamicsTension = 300;
        strokeAnimation.completionBlock = ^void(POPAnimation *anim, BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self completeAnimation];
            });
        };
        [shapeLayer pop_addAnimation:strokeAnimation forKey:@"strokeEndAnimation"];
    }
}

@end
