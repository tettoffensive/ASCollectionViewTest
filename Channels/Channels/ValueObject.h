//
//  ValueObject.h
//  Channels
//
//  Created by Stuart Tett on 9/9/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValueObject : NSObject <NSCopying>

- (instancetype)initWithBackingObject:(id)backingObject;

@property (nonatomic, readonly) id backingObject;

@end
