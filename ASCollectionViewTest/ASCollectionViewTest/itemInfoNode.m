//
//  ItemInfoNode.m
//
//  Created by Stuart Tett on 9/11/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ItemInfoNode.h"
#import "ListerViewModel.h"

@import AsyncDisplayKit;

static CGFloat kTextPadding = 10.0f;

@interface ItemInfoNode () <ASTextNodeDelegate,ASNetworkImageNodeDelegate>
{
    ASTextNode *_titleNode;
    ASNetworkImageNode *_imageNode;
    ItemInfo *_info;
}
@end

@implementation ItemInfoNode

- (instancetype)initWithInfo:(ItemInfo*)info
{
    if ( self = [super init]) {
        
        _info = info;
        
        [self setBackgroundColor:[UIColor blackColor]];
        
        // create a text node
        _titleNode = [ASTextNode new];
        _titleNode.delegate = self;
        _titleNode.userInteractionEnabled = NO;
        NSString *title = info.title;
        
        NSShadow *dropShadow = [NSShadow new];
        [dropShadow setShadowOffset:CGSizeMake(0, 1)];
        [dropShadow setShadowColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.25]];
        [dropShadow setShadowBlurRadius:2];
        
        if (title && title.length > 0) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                                                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:20],
                                                                                                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                                                     NSShadowAttributeName : dropShadow
                                                                                                                     }];
            _titleNode.attributedString = string;
        }
        
//        _imageNode = [ASNetworkImageNode new];
//        _imageNode.delegate = self;
//        [_imageNode setURL:[NSURL URLWithString:@"http://economictimes.indiatimes.com/thumb/msid-45891755,width-640,resizemode-4/nasas-images-of-most-remarkable-events-you-cant-miss.jpg"]];
        
        [self addSubnode:_imageNode];
        [self addSubnode:_titleNode];
    }
    return self;
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    // called on a background thread.  custom nodes must call -measure: on their subnodes in -calculateSizeThatFits:
    [_imageNode measure:CGSizeMake(constrainedSize.width, constrainedSize.height)];
    [_titleNode measure:CGSizeMake(constrainedSize.width  - 2 * kTextPadding,
                                  constrainedSize.height - 2 * kTextPadding)];
    CGFloat width = ((constrainedSize.width+20)*0.5)-20.;
    return CGSizeMake(width, width*1.22);
}

- (void)layout
{
    // called on the main thread.  we'll use the stashed size from above, instead of blocking on text sizing
    CGSize textNodeSize = _titleNode.calculatedSize;
    _titleNode.frame = CGRectMake(roundf(kTextPadding),
                                 roundf(self.calculatedSize.height-kTextPadding-textNodeSize.height),
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
    [self setNeedsLayout];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Touches
#pragma -------------------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

@end
