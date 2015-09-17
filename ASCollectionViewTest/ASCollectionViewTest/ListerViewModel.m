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
    [self willChangeValueForKey:@"itemList"];
    _itemList = @[
                  [[ItemInfo alloc] initWithBackingObject:@"0"],
                  [[ItemInfo alloc] initWithBackingObject:@"1"],
                  [[ItemInfo alloc] initWithBackingObject:@"2"],
                  [[ItemInfo alloc] initWithBackingObject:@"3"],
                  [[ItemInfo alloc] initWithBackingObject:@"4"],
                  [[ItemInfo alloc] initWithBackingObject:@"5"],
                  [[ItemInfo alloc] initWithBackingObject:@"6"],
                  [[ItemInfo alloc] initWithBackingObject:@"7"],
                  [[ItemInfo alloc] initWithBackingObject:@"8"],
                  [[ItemInfo alloc] initWithBackingObject:@"9"],
                  [[ItemInfo alloc] initWithBackingObject:@"10"],
                  [[ItemInfo alloc] initWithBackingObject:@"11"],
                  [[ItemInfo alloc] initWithBackingObject:@"12"],
                  ];
    [self didChangeValueForKey:@"itemList"];
}


@end


@implementation ItemInfo

- (instancetype)initWithBackingObject:(id)backingObject
{
    return [super initWithBackingObject:backingObject];
}

- (NSString *)title
{
    return self.backingObject;
}

@end
