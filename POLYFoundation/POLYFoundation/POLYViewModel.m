//
//  POLYViewModel.m
//  POLYFoundation
//
//  Created by Stuart Tett on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "POLYViewModel.h"
#import <objc/runtime.h>

@interface POLYViewModel ()
{
    NSArray<NSString *> *_keys;
}

@end

@implementation POLYViewModel

- (instancetype)init
{
    if (self = [super init]) {
        unsigned propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
        
        NSMutableArray<NSString *> *keys = [NSMutableArray arrayWithCapacity:propertyCount];
        
        unsigned i;
        for (i = 0; i < propertyCount; i++) {
            objc_property_t *thisProperty = propertyList + i;
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(*thisProperty)];
            [keys addObject:propertyName];
        }
        free(propertyList);
        
        _keys = [keys copy];
    }
    return self;
}

- (NSArray<NSString *> *)keys
{
    return _keys;
}

@end
