//
//  ChannelsNavigationBar.m
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsNavigationBar.h"
#import "ChannelsInterface.h"

@interface ChannelsNavigationBar ()
{
    UIView *_underlayView;
}
@end

@implementation ChannelsNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set Title Attributes
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [ChannelsInterface channelsGreenColor], NSForegroundColorAttributeName,
                                         [ChannelsInterface boldFontOfSize:18.0], NSFontAttributeName,
                                         nil];
    [self setTitleTextAttributes:titleTextAttributes];
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
    if (subview != _underlayView) {
        UIView *underlayView = self.underlayView;
        [underlayView removeFromSuperview];
        [self insertSubview:underlayView atIndex:1];
    }
}

- (UIView*) underlayView
{
    if(_underlayView == nil)
    {
        const CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        const CGSize selfSize = self.frame.size;
        
        _underlayView = [[UIView alloc] initWithFrame:CGRectMake(0, -statusBarHeight, selfSize.width, selfSize.height + statusBarHeight)];
        [_underlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [_underlayView setBackgroundColor:[ChannelsInterface navigationBarColor]];
        [_underlayView setAlpha:1.0f];
        [_underlayView setUserInteractionEnabled:NO];
    }
    
    return _underlayView;
}

@end
