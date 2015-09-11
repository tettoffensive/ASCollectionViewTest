//
//  ValueObject.m
//  Channels
//
//  Created by Stuart Tett on 9/9/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ValueObject.h"

@interface ValueObject ()

@property (nonatomic, strong) id backingObject;

@end

@implementation ValueObject

- (instancetype)initWithBackingObject:(id)backingObject
{
    self = [super init];
    if (!self) return nil;
    
    _backingObject = backingObject;
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) return YES;
    if (![other isKindOfClass:self.class]) return NO;
    return [self isEqualToValueObject:other];
}

- (BOOL)isEqualToValueObject:(ValueObject*)otherValueObject
{
    return [self.backingObject isEqual:otherValueObject.backingObject];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%p: %@> {Value: %@}", self, self.class, self.backingObject];
}

- (NSComparisonResult)compare:(ValueObject*)otherValueObject
{
    return [self.backingObject compare:otherValueObject.backingObject];
}

- (NSUInteger)hash
{
    return [self.backingObject hash];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[self.class allocWithZone:zone] initWithBackingObject:self.backingObject];
}

@end