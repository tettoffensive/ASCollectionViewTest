//
//  UIView+POLYAdditions.m
//  Channels
//
//  Created by Stuart Tett on 9/3/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "UIView+POLYAdditions.h"
#import "UIQuery.h"

@implementation UIView (POLYAdditions)

- (void)applyScrimShadow
{
//    CALayer *layer = [[CALayer alloc] initWithLayer:self.layer];
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds,-15,-15)
                                              byRoundingCorners:UIRectCornerAllCorners
                                                    cornerRadii:CGSizeMake(10,10)] CGPath];
    self.layer.shadowColor = [UIColor colorWithHexString:@"#1f1712"].CGColor; // near black with some saturation and brightness (slightly warm). pure black looks bad
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 35;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5;
//    [self.layer addSublayer:layer];
//    layer.masksToBounds = NO;
}

@end
