//
//  POLYNetworking.h
//  POLYFoundation
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POLYNetworking : NSObject

- (instancetype)init NS_UNAVAILABLE NS_DESIGNATED_INITIALIZER;
+ (instancetype)sharedNetwork;

@end
