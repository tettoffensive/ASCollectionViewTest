//
//  POLYUploadManager.h
//  Tag
//
//  Created by Addison Hardy on 1/17/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

@import UIKit;

@interface POLYFileManager : NSObject

- (instancetype)initWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey NS_DESIGNATED_INITIALIZER;

- (NSURL *)getURLForFileWithKey:(NSString *)key;

- (void)downloadFileWithKey:(NSString *)key progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(NSData *))successBlock failure:(void (^)(NSError *err))failureBlock;
- (void)downloadImageWithKey:(NSString *)key progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(UIImage *image))successBlock failure:(void (^)(NSError *err))failureBlock;

- (NSString *)uploadFileData:(NSData *)data withContentType:(NSString *)contentType progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished))successBlock failure:(void (^)(NSError *err))failureBlock;
- (NSString *)uploadImage:(UIImage *)image progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished))successBlock failure:(void (^)(NSError *err))failureBlock;

// Only call on these two methods if you do not want a key to immediately return and instead from the success block handlers.
// This is safer to use as it gaurantees the a sequence of objects that are needed for uploading are executing in the right order.
- (void)newUploadImage:(UIImage *)image progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished, NSString *key))successBlock failure:(void (^)(NSError *err))failureBlock;
- (void)newUploadVideoData:(NSData *)data progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished, NSString *key))successBlock failure:(void (^)(NSError *err))failureBlock;

- (void)performBlock:(void (^)())block afterRequestWithKey:(NSString *)key;

- (CGFloat)percentageCompleteForUploadWithKey:(NSString *)key;

- (CGFloat)percentageCompleteForAllDownloads;
- (CGFloat)percentageCompleteForAllUploads;

- (void)restartUploadWithKey:(NSString *)key;
- (void)cancelUploadWithKey:(NSString *)key;

- (void)cancelAllTransfers;

@end
