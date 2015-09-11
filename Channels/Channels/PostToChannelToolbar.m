//
//  PostToChannelToolbar.m
//  Channels
//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "PostToChannelToolbar.h"
#import "ChannelsInterface.h"

@interface PostToChannelToolbar()

@property (nonatomic, strong) UIView *viewContainer;

@end

@implementation PostToChannelToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _viewContainer = [[UIView alloc] initWithFrame:self.bounds];
        _viewContainer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
        [self addSubview:_viewContainer];
        
        _titleLabel = [[UILabel alloc] initWithFrame:_viewContainer.bounds];
        [_titleLabel setText:@"Pick channel"];
        [_titleLabel setTextColor:[ChannelsInterface channelsGreyColor]];
        [_titleLabel setFont:[ChannelsInterface mediumFontOfSize:16.0]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel sizeToFit];
        _titleLabel.center = CGPointMake(_viewContainer.bounds.size.width/2.0, _viewContainer.bounds.size.height/2.0);
        [_viewContainer addSubview:_titleLabel];
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(_viewContainer.bounds.origin.x,
                                                                 _viewContainer.bounds.origin.y,
                                                                 50.0f, 50.0f)];
        [_leftButton setImage:[UIImage imageNamed:@"Pick Channel"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_viewContainer addSubview:_leftButton];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(_viewContainer.bounds.size.width - 50.0f,
                                                                  _viewContainer.bounds.origin.y,
                                                                  50.0f, 50.0f)];
        [_rightButton setImage:[UIImage imageNamed:@"Post To Channel"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setEnabled:NO];
        [_viewContainer addSubview:_rightButton];
    }
    return self;
}

- (void)updateToolbarTitle:(NSString *)title
{
    [_titleLabel setText:title];
    [_titleLabel sizeToFit];
    _titleLabel.center = CGPointMake(_viewContainer.bounds.size.width/2.0, _viewContainer.bounds.size.height/2.0);
}

- (void)leftButtonAction
{
    NSLog(@"leftButtonAction");
}

- (void)rightButtonAction
{
    NSLog(@"rightButtonAction");
}

@end
