
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
    
    [dictionary setObject: progressBlockCopy forKey: @"progress"];
    [dictionary setObject: successBlockCopy forKey: @"success"];
    [dictionary setObject: failureBlockCopy forKey: @"failure"];
    
    // Completion percentage
    [dictionary setObject: [NSNumber numberWithFloat: 0.0] forKey: @"percent"];
    
    // Array of pending blocks
    NSMutableArray *pending = [[NSMutableArray alloc] init];
    [dictionary setObject: pending forKey: @"pending"];
    
    [self.downloads setObject: dictionary forKey: key];
    
    S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey: key withBucket: self.s3Bucket];
    [request setDate: [POLYDate correctDate]];
    [request setDelegate: self];
    [request setRegionName: self.s3Region];
    [request setRequestTag: key];
    
    [self.s3 getObject: request];
    
    [[self.downloads objectForKey: key] setObject: request forKey: @"request"];
    
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
    
    [dictionary setObject: progressBlockCopy forKey: @"progress"];
    [dictionary setObject: successBlockCopy forKey: @"success"];
    [dictionary setObject: failureBlockCopy forKey: @"failure"];
    
    // Completion percentage
    [dictionary setObject: [NSNumber numberWithFloat: 0.0] forKey: @"percent"];
    
    // Array of pending blocks
    NSMutableArray *pending = [[NSMutableArray alloc] init];
    [dictionary setObject: pending forKey: @"pending"];
    
    [self.uploads setObject: dictionary forKey: key];
    
    S3PutObjectRequest *request = [[S3PutObjectRequest alloc] initWithKey: key inBucket: self.s3Bucket];
    [request setCacheControl: @"max-age=31536000"];
    [request setContentType: contentType];
    [request setData:data];
    [request setDate:[POLYDate correctDate]];
    [request setDelegate: self];
    [request setRegionName: self.s3Region];
    [request setRequestTag: key];
    
    [self.s3tm upload: request];
    
    [[self.uploads objectForKey: key] setObject: request forKey: @"request"];
    
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
        
        for (void (^block)() in [[self.downloads objectForKey: key] objectForKey: @"pending"]) {
            
            block();
            
        }
        
        [[[self.downloads objectForKey: key] objectForKey: @"pending"] removeAllObjects];
        
    } else if ([[self.uploads allKeys] containsObject: key]) {
        
        for (void (^block)() in [[self.uploads objectForKey: key] objectForKey: @"pending"]) {
            
            block();
            
        }
        
        [[[self.uploads objectForKey: key] objectForKey: @"pending"] removeAllObjects];
        
    }
    
}

- (void)removePendingBlocksForRequestWithKey:(NSString *)key
{
    if ([[self.downloads allKeys] containsObject: key]) {
        
        [[[self.downloads objectForKey: key] objectForKey: @"pending"] removeAllObjects];
        
    } else if ([[self.uploads allKeys] containsObject: key]) {
        
        [[[self.uploads objectForKey: key] objectForKey: @"pending"] removeAllObjects];
        
    }
}

- (void)performBlock:(void (^)())block afterRequestWithKey:(NSString *)key
{
    if ([[self.downloads allKeys] containsObject: key]) {
        
        [[[self.downloads objectForKey: key] objectForKey: @"pending"] addObject: block];
        
    } else if ([[self.uploads allKeys] containsObject: key]) {
        
        [[[self.uploads objectForKey: key] objectForKey: @"pending"] addObject: block];
        
    } else {
        
        if (block) block();
        
    }
}

- (CGFloat)percentageCompleteForUploadWithKey:(NSString *)key
{
    CGFloat percentage = -1.0;
    
    if ([[self.uploads allKeys] containsObject: key]) {
        percentage = [[[self.uploads objectForKey: key] valueForKey: @"percentage"] floatValue];
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
        S3PutObjectRequest *request = [[self.uploads objectForKey: key] objectForKey: @"request"];
        [request setDelegate: self];
        [self.s3tm upload: request];
    }
}

- (void)cancelUploadWithKey:(NSString *)key
{
    [[[self.uploads objectForKey: key] objectForKey: @"request"] cancel];
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
        
        [[self.downloads objectForKey: request.requestTag] setObject: [NSNumber numberWithFloat: percentage] forKey: @"percentage"];
        progressCallback = [[self.downloads objectForKey: request.requestTag] objectForKey: @"progress"];
        
    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
        
        [[self.uploads objectForKey: request.requestTag] setObject: [NSNumber numberWithFloat: percentage] forKey: @"percentage"];
        progressCallback = [[self.uploads objectForKey: request.requestTag] objectForKey: @"progress"];
        
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
        
        failureCallback = [[self.downloads objectForKey:request.requestTag] objectForKey: @"failure"];
        if (failureCallback) failureCallback(error);
        
        [self.downloads removeObjectForKey: request.requestTag];
        
    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
        
        failureCallback = [[self.uploads objectForKey:request.requestTag] objectForKey: @"failure"];
        if (failureCallback) failureCallback(error);
        
    }
    
}

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
//    [[POLYNetworking sharedNetwork] reportErrorWithMessage: [[NSString alloc] initWithData: response.body encoding: NSUTF8StringEncoding]];
    
    [self performPendingBlocksForRequestWithKey: request.requestTag];
    
    if ([[self.downloads allKeys] containsObject: request.requestTag]) {
        
        void (^successCallback)(NSData *data) = [[self.downloads objectForKey:request.requestTag] objectForKey: @"success"];
        successCallback([response body]);
        
        [self.downloads removeObjectForKey: request.requestTag];
        
    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
        
        void (^successCallback)(BOOL finished) = [[self.uploads objectForKey:request.requestTag] objectForKey: @"success"];
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