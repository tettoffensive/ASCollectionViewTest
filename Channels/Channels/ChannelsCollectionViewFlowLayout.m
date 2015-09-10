//
//  ChannelsCollectionViewFlowLayout.m
//  Channels
//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsCollectionViewFlowLayout.h"

@implementation ChannelsCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        CGFloat spacing = 4.0;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minimumInteritemSpacing = spacing;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = spacing;
    }
    return self;
}

@end