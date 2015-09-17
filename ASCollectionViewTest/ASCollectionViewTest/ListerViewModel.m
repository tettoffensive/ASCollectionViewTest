//
//  ListerViewModel.m
//
//  Created by Stuart Tett on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ListerViewModel.h"

@implementation ListerViewModel

- (instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}

- (void)updateList
{

}


@end


@implementation ItemInfo

- (instancetype)initWithBackingObject:(id)backingObject
{
    return [super initWithBackingObject:backingObject];
}

- (NSString *)title
{
    return [self.backingObject title];
}

@end
