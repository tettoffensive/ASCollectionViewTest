//
//  ChannelInfoNode.m
//  Channels
//
//  Created by Stuart Tett on 9/11/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelInfoNode.h"
#import "ChannelListerViewModel.h"

@import AsyncDisplayKit;

static CGFloat kTextPadding = 10.0f;

@interface ChannelInfoNode () <ASTextNodeDelegate,ASNetworkImageNodeDelegate>
{
    ASTextNode *_titleNode;
    ASTextNode *_updatedAtNode;
    ASNetworkImageNode *_imageNode;
}
@end

@implementation ChannelInfoNode

- (instancetype)initWithInfo:(ChannelInfo*)info
{
    if ( self = [super init]) {
        
        [self setBackgroundColor:[UIColor blackColor]];
        
        if (info.newPosts) {
            [self setAlpha:1.0];
        } else {
            [self setAlpha:0.35];
        }
        
        // create a text node
        _titleNode = [ASTextNode new];
        _titleNode.delegate = self;
        _titleNode.userInteractionEnabled = NO;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:info.title attributes:@{
                                                                                                                      NSFontAttributeName : [ChannelsInterface mediumFontOfSize:20],
                                                                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                                                                      }];
        _titleNode.attributedString = string;
        
        // create another text node for updated at
        _updatedAtNode = [ASTextNode new];
        _updatedAtNode.delegate = self;
        _updatedAtNode.userInteractionEnabled = NO;
        NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:@"49 minutes ago" attributes:@{
                                                                                                                      NSFontAttributeName : [ChannelsInterface regularFontOfSize:12],
                                                                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                                                                      }];
        [_updatedAtNode setAlpha:0.6];
        _updatedAtNode.attributedString = dateString;
        
        _imageNode = [ASNetworkImageNode new];
        _imageNode.delegate = self;
        [_imageNode setURL:info.thumbnailURL];
        
        [self addSubnode:_imageNode];
        [self addSubnode:_titleNode];
        [self addSubnode:_updatedAtNode];
    }
    return self;
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    // called on a background thread.  custom nodes must call -measure: on their subnodes in -calculateSizeThatFits:
    [_imageNode measure:CGSizeMake(constrainedSize.width, constrainedSize.height)];
    [_titleNode measure:CGSizeMake(constrainedSize.width  - 2 * kTextPadding,
                                  constrainedSize.height - 2 * kTextPadding)];
    [_updatedAtNode measure:CGSizeMake(constrainedSize.width  - 2 * kTextPadding,
                                        constrainedSize.height - 2 * kTextPadding)];
    CGFloat width = ((constrainedSize.width+20)*0.5)-20.;
    return CGSizeMake(width, width*1.22);
}

- (void)layout
{
    // called on the main thread.  we'll use the stashed size from above, instead of blocking on text sizing
    CGSize textNodeSize = _titleNode.calculatedSize;
    CGSize updatedAtNodeSize = _updatedAtNode.calculatedSize;
    _updatedAtNode.frame = CGRectMake(roundf(kTextPadding),
                                      roundf(self.calculatedSize.height-updatedAtNodeSize.height-kTextPadding),
                                      updatedAtNodeSize.width,
                                      updatedAtNodeSize.height);
    _titleNode.frame = CGRectMake(roundf(kTextPadding),
                                 roundf(self.calculatedSize.height-updatedAtNodeSize.height-kTextPadding-textNodeSize.height),
                                 textNodeSize.width,
                                 textNodeSize.height);
    
    // image should be size of parent node
    _imageNode.frame = CGRectMake(0, 0, self.calculatedSize.width, self.calculatedSize.height);
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ASNetworkImageNodeDelegate
#pragma -------------------------------------------------------------------------------------------

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image
{
    POLYLog(@"Loaded Image");
    [self setNeedsLayout];
}

@end
