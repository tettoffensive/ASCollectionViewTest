//
//  PostToChannelToolbar.h
//  Channels
//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostToChannelToolbar : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *leftButton;

- (void)updateToolbarTitle:(NSString *)title;

@end
