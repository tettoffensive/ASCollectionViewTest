
//  POLYUploadManager.m
//  Tag
//
//  Created by Addison Hardy on 1/17/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

#import "POLYFileManager.h"

#import <AWSS3/AWSS3.h>
#import <AWSS3/S3TransferManager.h>
#import <SDWebImage/SDWebImageManager.h>

@interface POLYFileManager() <AmazonServiceRequestDelegate>

@property (nonatomic, strong) AmazonS3Client *s3;
@property (nonatomic, strong) S3TransferManager *s3tm;

@property (nonatomic, strong) NSString *s3Bucket;
@property (nonatomic, strong) NSString *s3Region;

@property (nonatomic, strong) NSMutableDictionary *downloads;
@property (nonatomic, strong) NSMutableDictionary *uploads;

@end

@implementation POLYFileManager

- (instancetype)initWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey
{
    if (self = [super init]) {
        
        self.downloads = [[NSMutableDictionary alloc] init];
        self.uploads = [[NSMutableDictionary alloc] init];
        
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:accessKey withSecretKey:secretKey];
        
        self.s3tm = [S3TransferManager new];
        self.s3tm.delegate = self;
        self.s3tm.s3 = self.s3;
        self.s3tm.operationQueue.maxConcurrentOperationCount = 4;
        
        self.s3Bucket = @"swipe-app";
        self.s3Region = @"us-west-2";
        
    }
    
    return self;
    
}

- (NSURL *)getURLForFileWithKey:(NSString *)key
{
    if (key) {
        NSString *url = [NSString stringWithFormat: @"http://cdn.joinswipe.com/%@", key];
        return [NSURL URLWithString: url];
    } else {
        return nil;
    }
}

- (void)downloadFileWithKey:(NSString *)key progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(NSData *))successBlock failure:(void (^)(NSError *err))failureBlock
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    // Callback blocks
    void (^progressBlockCopy)(CGFloat progress) = [progressBlock copy];
    void (^successBlockCopy)(NSData *data) = [successBlock copy];
    void (^failureBlockCopy)(NSError *err) = [failureBlock copy];
    
    dictionary[@"progress"] = progressBlockCopy;
    dictionary[@"success"] = successBlockCopy;
    dictionary[@"failure"] = failureBlockCopy;
    
    // Completion percentage
    dictionary[@"percent"] = @0.0f;
    
    // Array of pending blocks
    NSMutableArray *pending = [[NSMutableArray alloc] init];
    dictionary[@"pending"] = pending;
    
    (self.downloads)[key] = dictionary;
    
    S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey: key withBucket: self.s3Bucket];
    [request setDate: [POLYDate correctDate]];
    [request setDelegate: self];
    [request setRegionName: self.s3Region];
    [request setRequestTag: key];
    
    [self.s3 getObject: request];
    
    (self.downloads)[key][@"request"] = request;
    
}

- (void) downloadImageWithKey:(NSString *)key progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(UIImage *))successBlock failure:(void (^)(NSError *err))failureBlock
{
    if (!key || [key isEqualToString: @""]) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful. Empty key provided", nil), };
        NSError *error = [NSError errorWithDomain:@"POLYFileManagerErrorDomain" code:-57 userInfo:userInfo];
        if (failureBlock) failureBlock(error);
    } else {
    
        [self downloadFileWithKey: key progress:^(CGFloat progress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock) progressBlock(progress);
            });
            
        } success:^(NSData *data) {
            
            UIImage *image = [UIImage imageWithData: data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock) successBlock(image);
            });
            
        } failure:^(NSError *err) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) failureBlock(err);
            });
            
        }];
        
    }
    
}

- (NSString *)uploadFileData:(NSData *)data withContentType:(NSString *)contentType progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished))successBlock failure:(void (^)(NSError *err))failureBlock
{
    NSString *key = [[NSUUID UUID] UUIDString];
    
    if ([contentType isEqualToString: @"image/jpeg"]) {
        key = [key stringByAppendingString: @".jpeg"];
    } else if ([contentType isEqualToString: @"image/webp"]) {
        key = [key stringByAppendingString: @".webp"];
    } else if ([contentType isEqualToString: @"video/mp4"]) {
        key = [key stringByAppendingString: @".mp4"];
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    // Callback blocks
    void (^progressBlockCopy)(CGFloat progress) = [progressBlock copy];
    void (^successBlockCopy)(BOOL finished) = [successBlock copy];
    void (^failureBlockCopy)(NSError *err) = [failureBlock copy];
    
    dictionary[@"progress"] = progressBlockCopy;
    dictionary[@"success"] = successBlockCopy;
    dictionary[@"failure"] = failureBlockCopy;
    
    // Completion percentage
    dictionary[@"percent"] = @0.0f;
    
    // Array of pending blocks
    NSMutableArray *pending = [[NSMutableArray alloc] init];
    dictionary[@"pending"] = pending;
    
    (self.uploads)[key] = dictionary;
    
    S3PutObjectRequest *request = [[S3PutObjectRequest alloc] initWithKey: key inBucket: self.s3Bucket];
    [request setCacheControl: @"max-age=31536000"];
    [request setContentType: contentType];
    [request setData:data];
    [request setDate:[POLYDate correctDate]];
    [request setDelegate: self];
    [request setRegionName: self.s3Region];
    [request setRequestTag: key];
    
    [self.s3tm upload: request];
    
    (self.uploads)[key][@"request"] = request;
    
    return key;
    
}

- (NSString *)uploadImage:(UIImage *)image progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished))successBlock failure:(void (^)(NSError *err))failureBlock
{
    NSData *resampled = UIImageJPEGRepresentation(image, 0.85);
    
    NSString *key = [self uploadFileData: resampled withContentType: @"image/jpeg" progress:^(CGFloat progress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(progress);
        });
        
    } success:^(BOOL finished) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(finished);
        });
        
    } failure:^(NSError *err) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(err);
        });
        
    }];
    
    return key;
    
}

- (void)performPendingBlocksForRequestWithKey:(NSString *)key
{
    if ([[self.downloads allKeys] containsObject: key]) {
        
        for (void (^block)() in (self.downloads)[key][@"pending"]) {
            
            block();
            
        }
        
        [(self.downloads)[key][@"pending"] removeAllObjects];
        
    } else if ([[self.uploads allKeys] containsObject: key]) {
        
        for (void (^block)() in (self.uploads)[key][@"pending"]) {
            
            block();
            
        }
        
        [(self.uploads)[key][@"pending"] removeAllObjects];
        
    }
    
}

- (void)removePendingBlocksForRequestWithKey:(NSString *)key
{
    if ([[self.downloads allKeys] containsObject: key]) {
        
        [(self.downloads)[key][@"pending"] removeAllObjects];
        
    } else if ([[self.uploads allKeys] containsObject: key]) {
        
        [(self.uploads)[key][@"pending"] removeAllObjects];
        
    }
}

- (void)performBlock:(void (^)())block afterRequestWithKey:(NSString *)key
{
    if ([[self.downloads allKeys] containsObject: key]) {
        
        [(self.downloads)[key][@"pending"] addObject: block];
        
    } else if ([[self.uploads allKeys] containsObject: key]) {
        
        [(self.uploads)[key][@"pending"] addObject: block];
        
    } else {
        
        if (block) block();
        
    }
}

- (CGFloat)percentageCompleteForUploadWithKey:(NSString *)key
{
    CGFloat percentage = -1.0;
    
    if ([[self.uploads allKeys] containsObject: key]) {
        percentage = [[(self.uploads)[key] valueForKey: @"percentage"] floatValue];
    }
    
    return percentage;
}

- (CGFloat)percentageCompleteForAllDownloads
{
    if ([self.downloads count] > 0) {
        
        CGFloat percentage = 0.0;
        
        for (NSDictionary *download in [self.downloads allValues]) {
            
            percentage += [[download valueForKey: @"percentage"] floatValue];
            
        }
        
        return (percentage / (CGFloat)[self.downloads count]);
        
    } else {
        
        return 1.0;
        
    }
}

- (CGFloat)percentageCompleteForAllUploads
{
    if ([self.uploads count] > 0) {
        
        CGFloat percentage = 0.0;
        
        for (NSDictionary *upload in [self.uploads allValues]) {
            percentage += [[upload valueForKey: @"percentage"] floatValue];
        }
        
        return (percentage / (CGFloat)[self.uploads count]);
        
    } else {
        
        return 1.0;
        
    }
}

- (void)restartUploadWithKey:(NSString *)key
{
    if ([[self.uploads allKeys] containsObject: key]) {
        S3PutObjectRequest *request = (self.uploads)[key][@"request"];
        [request setDelegate: self];
        [self.s3tm upload: request];
    }
}

- (void)cancelUploadWithKey:(NSString *)key
{
    [(self.uploads)[key][@"request"] cancel];
    [self.uploads removeObjectForKey: key];
}

- (void)cancelAllTransfers
{
    [self.s3tm cancelAllTransfers];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Private Methods
#pragma -------------------------------------------------------------------------------------------

- (void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    CGFloat percentage = ((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
    void (^progressCallback)(CGFloat progress);
    
    if ([[self.downloads allKeys] containsObject: request.requestTag]) {
        
        (self.downloads)[request.requestTag][@"percentage"] = @(percentage);
        progressCallback = (self.downloads)[request.requestTag][@"progress"];
        
    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
        
        (self.uploads)[request.requestTag][@"percentage"] = @(percentage);
        progressCallback = (self.uploads)[request.requestTag][@"progress"];
        
    }
    
    if (progressCallback) {
        progressCallback(percentage);
    }
    
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    void (^failureCallback)(NSError *err);
    
    [self removePendingBlocksForRequestWithKey: request.requestTag];
    
    if ([[self.downloads allKeys] containsObject: request.requestTag]) {
        
        failureCallback = (self.downloads)[request.requestTag][@"failure"];
        if (failureCallback) failureCallback(error);
        
        [self.downloads removeObjectForKey: request.requestTag];
        
    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
        
        failureCallback = (self.uploads)[request.requestTag][@"failure"];
        if (failureCallback) failureCallback(error);
        
    }
    
}

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
//    [[POLYNetworking sharedNetwork] reportErrorWithMessage: [[NSString alloc] initWithData: response.body encoding: NSUTF8StringEncoding]];
    
    [self performPendingBlocksForRequestWithKey: request.requestTag];
    
    if ([[self.downloads allKeys] containsObject: request.requestTag]) {
        
        void (^successCallback)(NSData *data) = (self.downloads)[request.requestTag][@"success"];
        successCallback([response body]);
        
        [self.downloads removeObjectForKey: request.requestTag];
        
    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
        
        void (^successCallback)(BOOL finished) = (self.uploads)[request.requestTag][@"success"];
        successCallback(YES);
        
        [self.uploads removeObjectForKey: request.requestTag];
        
    }
    
}

// Part of the new SPOperationQueue implementation.

- (void)newUploadVideoData:(NSData *)data progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished, NSString *key))successBlock failure:(void (^)(NSError *err))failureBlock
{
    __block NSString *key = [self uploadFileData:data withContentType:@"video/mp4" progress:^(CGFloat progress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(progress);
        });
        
    } success:^(BOOL finished) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(finished, key);
        });
        
    } failure:^(NSError *err) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(err);
        });
        
    }];
}


- (void)newUploadImage:(UIImage *)image progress:(void (^)(CGFloat progress))progressBlock success:(void (^)(BOOL finished, NSString *key))successBlock failure:(void (^)(NSError *err))failureBlock
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        NSData *resampled = UIImageJPEGRepresentation(image, 0.85);
        
        __block NSString *key = [self uploadFileData: resampled withContentType: @"image/jpeg" progress:^(CGFloat progress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(progress);
            });
            
        } success:^(BOOL finished) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(finished, key);
            });
            
        } failure:^(NSError *err) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(err);
            });
            
        }];
    });
}

@end