//
//  PostToChannelCollectionViewCell.m

//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "PostToChannelCollectionViewCell.h"
#import "ChannelsInterface.h"

@interface PostToChannelCollectionViewCell()
{
    IBOutlet UIView *_channelImageContainer;
}

@end

@implementation PostToChannelCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setupCellWithChannel:(ChannelModel *)channel
{
    if ([channel.channelID isEqualToString:@"Create Channel"]) {
        [self showHideShadow:NO];
        [self setChannelTitleAttributedTextWithString:@""];
        self.channelImageView.image = [UIImage imageNamed:@"Create Channel Button"];
    } else {
        [self showHideShadow:YES];
        [self setChannelTitleAttributedTextWithString:channel.title];
        self.channelImageView.image = [UIImage imageNamed:@"Cell Placeholder"];
    }
}

- (void)showHideShadow:(BOOL)show
{
    if (show) {
        _channelImageContainer.clipsToBounds = NO;
        _channelImageContainer.layer.shadowColor = [UIColor blackColor].CGColor;
        _channelImageContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:_channelImageContainer.bounds].CGPath;
        _channelImageContainer.layer.shadowRadius = 1.0f;
        _channelImageContainer.layer.shadowOpacity = 0.5f;
        _channelImageContainer.layer.shadowOffset = CGSizeZero;
    } else {
        _channelImageContainer.clipsToBounds = NO;
        _channelImageContainer.layer.shadowColor = nil;
        _channelImageContainer.layer.shadowPath = nil;
        _channelImageContainer.layer.shadowRadius = 0.0f;
        _channelImageContainer.layer.shadowOpacity = 0.0f;
        _channelImageContainer.layer.shadowOffset = CGSizeZero;
    }
}

- (void)setChannelTitleAttributedTextWithString:(NSString *)text
{
    _channelTitleLabel.attributedText = [self channelTitleAttributedString:text];
}

- (NSMutableAttributedString *)channelTitleAttributedString:(NSString *)input
{
    NSMutableAttributedString *labelAttributes = [[NSMutableAttributedString alloc] initWithString:input];
    [labelAttributes addAttribute:NSFontAttributeName value:[ChannelsInterface regularFontOfSize:14.0] range:NSMakeRange(0, labelAttributes.length)];
    [labelAttributes addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, labelAttributes.length)];
    return labelAttributes;
}

@end
