
//  POLYUploadManager.m
//  Tag
//
//  Created by Addison Hardy on 1/17/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

#import "POLYFileManager.h"

@import AWSCore;
@import MobileCoreServices;

#import <SDWebImage/SDWebImageManager.h>

@interface POLYFileManager()
{
    // background queues to manage calls to caching uploads/downloads on background threads (avoid race-conditions)
    dispatch_queue_t _uploadsCacheQueue;
    dispatch_queue_t _downloadsCacheQueue;
}

@property (nonatomic, strong) AWSS3TransferManager *transferManager;
@property (nonatomic, strong) NSMutableDictionary  *downloads;
@property (nonatomic, strong) NSMutableDictionary  *uploads;

@end

@implementation POLYFileManager

- (instancetype)initWithAccessKey:(NSString *)accessKey
                    withSecretKey:(NSString *)secretKey
{
    if (self = [super init]) {
        _uploadsCacheQueue   = dispatch_queue_create("com.ComplexPolygon.uploadscache", DISPATCH_QUEUE_CONCURRENT);
        _downloadsCacheQueue = dispatch_queue_create("com.ComplexPolygon.downloadscache", DISPATCH_QUEUE_CONCURRENT);
        
        _downloads = [NSMutableDictionary new];
        _uploads = [NSMutableDictionary new];
        
        _subpath = @"";
        _region = AWSRegionUSWest2;
        _baseURLString = @"http://cdn.joinswipe.com";
        
        AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:_region credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        _transferManager = [AWSS3TransferManager defaultS3TransferManager];
    }
    return self;
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Download Files
#pragma -------------------------------------------------------------------------------------------

- (AWSTask *)downloadFileWithKey:(NSString *)key
                   progress:(void (^)(CGFloat progress))progressBlock
                    success:(void (^)(NSURL *))successBlock
                    failure:(void (^)(NSError *err))failureBlock
{
    NSParameterAssert(key);
    NSParameterAssert(self.bucket);
    NSParameterAssert(self.subpath);
    
    NSURL* fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:key]];
    
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    [downloadRequest setBucket:self.bucket];
    [downloadRequest setKey:[[self.subpath stringByAppendingString:@"/"] stringByAppendingString:key]];
    [downloadRequest setDownloadingFileURL:fileURL];
    [downloadRequest setDownloadProgress:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        CGFloat percentage = ((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) progressBlock(percentage);
        });
    }];
    
    [self setDownloadCacheObject:downloadRequest forKey:key];
    
    __weak __typeof(self)weakSelf = self;
    return [[self.transferManager download:downloadRequest]
     continueWithBlock:^id(AWSTask *task) {
         
         __strong __typeof(weakSelf)strongSelf = weakSelf;
         [strongSelf clearDownloadCacheObject:key];
         
         if (task.error){
             if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                 switch (task.error.code) {
                     case AWSS3TransferManagerErrorCancelled:
                     case AWSS3TransferManagerErrorPaused:
                         break;
                         
                     default:
                         POLYLog(@"Error: %@", task.error);
                         break;
                 }
             } else {
                 // Unknown error.
                 POLYLog(@"Error: %@", task.error);
             }
             
             if (failureBlock) failureBlock(task.error);
         }
         
         if(successBlock) successBlock(downloadRequest.downloadingFileURL);
         
         return nil;
     }];
}

- (AWSTask *)downloadImageWithKey:(NSString *)key
                    progress:(void (^)(CGFloat progress))progressBlock
                     success:(void (^)(UIImage *))successBlock
                     failure:(void (^)(NSError *err))failureBlock
{
    if (!key || [key isEqualToString: @""]) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful. Empty key provided", nil), };
        NSError *error = [NSError errorWithDomain:@"POLYFileManagerErrorDomain" code:-57 userInfo:userInfo];
        if (failureBlock) failureBlock(error);
        
        return [AWSTask taskWithError:error];
        
    } else {
        return [self downloadFileWithKey:key progress:^(CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock) progressBlock(progress);
            });
        } success:^(NSURL *downloadingFilePath) {
            NSData *data = [NSData dataWithContentsOfURL:downloadingFilePath];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successBlock) successBlock(image);
            });
        } failure:^(NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) failureBlock(err);
            });
        }];
    }
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Upload Files
#pragma -------------------------------------------------------------------------------------------

- (AWSTask *)uploadFileData:(NSData *)data
            withContentType:(NSString *)contentType
                   progress:(void (^)(CGFloat progress))progressBlock
                    success:(void (^)(BOOL finished, NSString *key))successBlock
                    failure:(void (^)(NSError *err))failureBlock
{
    NSParameterAssert(data);
    NSParameterAssert(self.bucket);
    NSParameterAssert(self.subpath);

    
    // Build a key based off the content type
    NSString *key = [[NSUUID UUID] UUIDString];
    NSString *extension = [self fileExtensionForMimeType:contentType];
    NSString *mediaKey = [key copy];
    if ([extension length] > 0) {
        key = [NSString stringWithFormat:@"%@.%@", key, extension];
    }
    
    // write data to disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [paths[0] stringByAppendingPathComponent:key];
    [data writeToFile:filePath atomically:YES];
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    [uploadRequest setContentType:contentType];
    [uploadRequest setContentLength:@([data length])];
    [uploadRequest setBucket:self.bucket];
    [uploadRequest setACL:AWSS3ObjectCannedACLPublicRead];
    if (self.subpath.length == 0) {
        [uploadRequest setKey:key];
    } else {
        [uploadRequest setKey:[[self.subpath stringByAppendingString:@"/"] stringByAppendingString:key]];
    }
    [uploadRequest setBody:fileURL];
    [uploadRequest setUploadProgress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        CGFloat percentage = ((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) progressBlock(percentage);
        });
    }];
    
    [self setUploadCacheObject:uploadRequest forKey:key];
    
    __weak __typeof(self)weakSelf = self;
    return [[self.transferManager upload:uploadRequest]
     continueWithBlock:^id(AWSTask *task) {

         __strong __typeof(weakSelf)strongSelf = weakSelf;
         [strongSelf clearUploadCacheObject:key];
         
         if (task.error) {
             if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                 switch (task.error.code) {
                     case AWSS3TransferManagerErrorCancelled:
                     case AWSS3TransferManagerErrorPaused:
                         break;
                     default:
                         POLYLog(@"Error: %@", task.error);
                         break;
                 }
             } else {
                 // Unknown error.
                 POLYLog(@"Error: %@", task.error);
             }
             if(failureBlock) failureBlock(task.error);
         }
         
         if(successBlock) successBlock(YES, mediaKey);
         
         return nil;
     }];
}

#pragma mark Upload Data Types

- (AWSTask *)uploadVideoData:(NSData *)data
                    progress:(void (^)(CGFloat progress))progressBlock
                     success:(void (^)(BOOL finished, NSString *key))successBlock
                     failure:(void (^)(NSError *err))failureBlock
{
    return [self uploadFileData:data
                withContentType:@"video/mp4"
                       progress:^(CGFloat progress) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (progressBlock) progressBlock(progress);
                           });
                       } success:^(BOOL finished, NSString *key) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (successBlock) successBlock(finished, key);
                           });
                       } failure:^(NSError *err) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (failureBlock) failureBlock(err);
                           });
                       }];
}


- (AWSTask *)uploadImage:(UIImage *)image
                progress:(void (^)(CGFloat progress))progressBlock
                 success:(void (^)(BOOL finished, NSString *key))successBlock
                 failure:(void (^)(NSError *err))failureBlock
{
    NSData *resampled = UIImageJPEGRepresentation(image, 0.85);
    
    return [self uploadFileData: resampled
                withContentType: @"image/jpeg"
                       progress:^(CGFloat progress) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (progressBlock) progressBlock(progress);
                           });
                       } success:^(BOOL finished, NSString *key) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (successBlock) successBlock(finished, key);
                           });
                       } failure:^(NSError *err) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (failureBlock) failureBlock(err);
                           });
                       }];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - File Transfer Management
#pragma -------------------------------------------------------------------------------------------

- (AWSTask *)pauseUploadWithKey:(NSString *)key
{
    AWSS3TransferManagerUploadRequest *uploadRequest = [self cacheUploadForKey:key];
    return [[uploadRequest pause] continueWithBlock:nil];
}

- (AWSTask *)restartUploadWithKey:(NSString *)key
{
    AWSS3TransferManagerUploadRequest *uploadRequest = [self cacheUploadForKey:key];
    return [self.transferManager upload:uploadRequest];
}

- (AWSTask *)cancelUploadWithKey:(NSString *)key
{
    AWSS3TransferManagerUploadRequest *uploadRequest = [self cacheUploadForKey:key];
    [self clearDownloadCacheObject:key];
    return [uploadRequest cancel];
}

- (AWSTask *)pauseDownloadWithKey:(NSString *)key
{
    AWSS3TransferManagerDownloadRequest *downloadRequest = [self cacheDownloadForKey:key];
    return [[downloadRequest pause] continueWithBlock:^id(AWSTask *task) {
        return nil;
    }];
}

- (AWSTask *)restartDownloadWithKey:(NSString *)key
{
    AWSS3TransferManagerDownloadRequest *downloadRequest = [self cacheDownloadForKey:key];
    return [self.transferManager download:downloadRequest];
}

- (AWSTask *)cancelDownloadWithKey:(NSString *)key
{
    AWSS3TransferManagerDownloadRequest *downloadRequest = [self cacheDownloadForKey:key];
    [self clearDownloadCacheObject:key];
    return [downloadRequest cancel];
}

- (AWSTask *)pauseAllTransfers
{
    return [self.transferManager pauseAll];
}

- (AWSTask *)resumeAllTransfers
{
    return [self.transferManager resumeAll:^(AWSRequest *request) {
        return;
    }];
}

- (AWSTask *)cancelAllTransfers
{
    return [self.transferManager cancelAll];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Utilities
#pragma -------------------------------------------------------------------------------------------

- (NSURL *)getURLForFileWithKey:(NSString *)key
{
    if (key) {
        NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseURLString, key];
        return [NSURL URLWithString:url];
    } else {
        return nil;
    }
}

- (id)cacheUploadForKey:(id)key
{
    __block id obj;
    dispatch_sync(_uploadsCacheQueue, ^{
        obj = (self.uploads)[key];
    });
    return obj;
}

- (void)setUploadCacheObject:(id)obj forKey: (id)key
{
    NSParameterAssert(obj != nil);
    dispatch_barrier_async(_uploadsCacheQueue, ^{
        (self.uploads)[key] = obj;
    });
}

- (void)clearUploadCacheObject:(id)key
{
    dispatch_barrier_async(_uploadsCacheQueue, ^{
        [self.uploads removeObjectForKey:key];
    });
}

- (id)cacheDownloadForKey:(id)key
{
    __block id obj;
    dispatch_sync(_downloadsCacheQueue, ^{
        obj = (self.downloads)[key];
    });
    return obj;
}

- (void)setDownloadCacheObject:(id)obj forKey:(id)key
{
    NSParameterAssert(obj != nil);
    dispatch_barrier_async(_uploadsCacheQueue, ^{
        (self.downloads)[key] = obj;
    });
}

- (void)clearDownloadCacheObject:(id)key
{
    dispatch_barrier_async(_downloadsCacheQueue, ^{
        [self.downloads removeObjectForKey:key];
    });
}

- (NSString *) fileExtensionForMimeType:(NSString *)type
{
    CFStringRef mimeType = (__bridge CFStringRef)type;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
    CFStringRef extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    
    NSString *ext = (__bridge_transfer NSString *)extension;
    
    if (uti) CFRelease(uti);
    
    return ext;
}

@end
