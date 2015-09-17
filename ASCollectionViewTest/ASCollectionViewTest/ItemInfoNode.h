//
//  ItemInfoNode.h
//
//  Created by Stuart Tett on 9/11/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@class ItemInfo;
@class ItemInfoNode;

@interface ItemInfoNode : ASCellNode
- (instancetype)initWithInfo:(ItemInfo*)info;
@end
