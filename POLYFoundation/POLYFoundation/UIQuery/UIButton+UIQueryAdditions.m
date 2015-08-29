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

#import "UIButton+UIQueryAdditions.h"
#import "UIQueryShortcuts.h"
#import "UIView+UIQueryAdditions.h"

@implementation UIButton (UIQuery)

- (id)initWithImageName:(NSString *)imageName
{
    NSString *imageNameForNormalState = [NSString stringWithFormat:@"%@", imageName];
    NSString *imageNameForHighlightedState = [NSString stringWithFormat:@"%@_highlighted", imageName];
    NSString *imageNameForSelectedState = [NSString stringWithFormat:@"%@_highlighted", imageName];
    
    UIImageView *imageViewForNormalState = UIQueryImageView(imageNameForNormalState);
    UIImage *imageViewForHighlightedState = UIQueryImage(imageNameForHighlightedState);
    UIImage *imageViewForSelectedState = UIQueryImage(imageNameForSelectedState);
    
    if (self = [super initWithFrame:imageViewForNormalState.frame]) {
        [self setImage:imageViewForNormalState.image forState:UIControlStateNormal];
        [self setImage:imageViewForHighlightedState forState:UIControlStateHighlighted];
        [self setImage:imageViewForSelectedState forState:UIControlStateSelected];
    }
    
    return self;
}

- (void)setWidth:(CGFloat)width
{
    [super setWidth:width];
    for (UIView *view in self.subviews) {
        [view centerAlignInView:self];
    }
}

- (void)setHeight:(CGFloat)height
{
    [super setHeight:height];
    for (UIView *view in self.subviews) {
        [view middleAlignInView:self];
    }
}

@end
