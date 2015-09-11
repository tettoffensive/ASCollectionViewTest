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
    ASTextNode *_textNode;
    ASNetworkImageNode *_imageNode;
}
@end

@implementation ChannelInfoNode

- (instancetype)initWithInfo:(ChannelInfo*)info
{
    if ( self = [super init]) {
        // create a text node
        _textNode = [[ASTextNode alloc] init];
        
        // configure the node to support tappable links
        _textNode.delegate = self;
        _textNode.userInteractionEnabled = NO;
        
        [self setBackgroundColor:[UIColor blackColor]];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:info.title attributes:@{
                                                                                                                      NSFontAttributeName : [ChannelsInterface mediumFontOfSize:20],
                                                                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                                                                      }];
        _textNode.attributedString = string;
        
        _imageNode = [ASNetworkImageNode new];
        _imageNode.delegate = self;
        [_imageNode setURL:info.thumbnailURL];
        
        [self addSubnode:_imageNode];
        [self addSubnode:_textNode];
    }
    return self;
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    // called on a background thread.  custom nodes must call -measure: on their subnodes in -calculateSizeThatFits:
    [_imageNode measure:CGSizeMake(constrainedSize.width, constrainedSize.height)];
    [_textNode measure:CGSizeMake(constrainedSize.width  - 2 * kTextPadding,
                                  constrainedSize.height - 2 * kTextPadding)];
    CGFloat width = ((constrainedSize.width+20)*0.5)-20.;
    return CGSizeMake(width, width*1.22);
}

- (void)layout
{
    // called on the main thread.  we'll use the stashed size from above, instead of blocking on text sizing
    CGSize textNodeSize = _textNode.calculatedSize;
    _textNode.frame = CGRectMake(roundf(kTextPadding),
                                 roundf(self.calculatedSize.height-textNodeSize.height-kTextPadding),
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
