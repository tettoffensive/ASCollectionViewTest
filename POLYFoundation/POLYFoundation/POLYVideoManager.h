//
//  POLYVideoManager.h
//  Swipe
//
//  Created by Addison Hardy on 11/25/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

@import Foundation;

@class POLYFileManager;

@interface POLYVideoManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)sharedInstance;

@property (nonatomic) POLYFileManager *fileManager;

- (void)discardVideoWithKey:(NSString *)key;
- (void)downloadVideoWithKey:(NSString *)key usingBlock:(void (^)(NSString *path))complete;

@end
