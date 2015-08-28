//
//  POLYNetworking.m
//  POLYFoundation
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "POLYNetworking.h"

@import AFNetworking;

@implementation POLYNetworking

+ (instancetype)sharedNetwork
{
    static POLYNetworking *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
//        NSURL *url = [NSURL URLWithString: CONFIG_BASE_URL];
//        self.api = [[AFHTTPSessionManager alloc] initWithBaseURL: url];
//        [self credentials];
    }
    return self;
}

@end
