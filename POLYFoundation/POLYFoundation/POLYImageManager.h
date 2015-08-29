//
//  POLYImageManager.h
//  Tag
//
//  Created by Addison Hardy on 6/10/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

@import UIKit;

@class POLYFileManager;

@interface POLYImageManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)sharedInstance;

@property (nonatomic) POLYFileManager *fileManager;

- (void)downloadImageWithKey:(NSString *)key cacheToDisk:(BOOL)diskCache withProgress:(void (^)(CGFloat percentage))progress usingBlock:(void (^)(BOOL finished, NSString *key, UIImage *image))complete;
- (void)downloadImageWithKey:(NSString *)key cacheToDisk:(BOOL)diskCache withProgress:(void (^)(CGFloat percentage))progress usingBlock:(void (^)(BOOL finished, NSString *key, UIImage *image))complete failure:(void(^)(NSError *error))failure;

@end
