/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Ryan Nelwan.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "UIView+UIQueryAdditions.h"
#import "UIQueryShortcuts.h"

@implementation UIView (UIQueryAdditions)

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setX:(CGFloat)x
{
    if (isnan(x)) {
        x = 0.0f;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    if (isnan(y)) {
        y = 0.0f;
    }
    
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)moveByX:(CGFloat)x
{
    if (isnan(x)) {
        x = 0.0f;
    }
    
    [self setX:self.x + x];
}

- (void)moveByY:(CGFloat)y
{
    if (isnan(y)) {
        y = 0.0f;
    }
    
    [self setY:self.y + y];
}

- (void)setWidth:(CGFloat)width
{
    if (isnan(width)) {
        width = 0.0f;
    }
    CGRect f = self.frame;
    f.size.width = width;
    self.frame = f;
}

- (void)setHeight:(CGFloat)height
{
    if (isnan(height)) {
        height = 0.0f;
    }
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (void)setOrigin:(CGPoint)origin
{
    if (isnan(origin.x)) {
        origin.x = 0.0f;
    }
    
    if (isnan(origin.y)) {
        origin.y = 0.0f;
    }
    
    [self setX:origin.x];
    [self setY:origin.y];
}

- (void)setSize:(CGSize)size
{
    [self setWidth:size.width];
    [self setHeight:size.height];
}

- (void)placeBeforeView:(UIView *)view
{
    [self setX:view.x - self.width];
}

- (void)placeAfterView:(UIView *)view
{
    [self setX:view.x + view.width];
}

- (void)placeBelowView:(UIView *)view
{
    [self setY:view.y + view.height];
}

- (void)centerAlignInView:(UIView *)view
{
    [self setX:view.width/2 - self.width/2];
}

- (void)centerAlign
{
    [self centerAlignInView:self.superview];
}

- (void)middleAlignInView:(UIView *)view
{
    [self setY:view.height/2 - self.height/2];
}

- (void)middleAlign
{
    [self middleAlignInView:self.superview];
}

- (CGAffineTransform)scaledTransformUsingSize:(CGSize)size
{
    CGSize scales = CGSizeMake(size.width/self.frame.size.width, size.height/self.frame.size.height);
    return CGAffineTransformMake(scales.width, 0, 0, scales.height, 0.0f, 0.0f);
}

-(void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    CGPoint position = self.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}

// Debugging Tools

- (void)debugHighlight
{
    self.backgroundColor = UIQueryRGBA(255, 0, 0, 0.1);
}

- (void)debugOutline
{
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = UIQueryRGBA(255, 0, 0, 0.8f).CGColor;
}

- (void)debugOutlineWithColor:(UIColor *)color
{
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = color.CGColor;
}

- (void)debugOutlineWithLabelString:(NSString *)string
{
    [self debugOutline];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
    label.text = string;
    label.font = [UIFont systemFontOfSize:10.0f];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.backgroundColor = [UIColor redColor];
    [self addSubview:label];
}

- (void)debugOutlineInMiddleWithLabelString:(NSString *)string
{
    [self debugOutline];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
    label.text = string;
    label.font = [UIFont systemFontOfSize:10.0f];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.backgroundColor = [UIColor redColor];
    [self addSubview:label];
    [label middleAlign];
}

@end
