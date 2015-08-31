
//  POLYUploadManager.m
//  Tag
//
//  Created by Addison Hardy on 1/17/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

#import "POLYFileManager.h"

@import AWSCore;

#import <SDWebImage/SDWebImageManager.h>

@interface POLYFileManager()

@property (nonatomic, strong) AWSS3TransferManager *transferManager;

@property (nonatomic, strong) NSMutableDictionary *downloads;
@property (nonatomic, strong) NSMutableDictionary *uploads;

@end

@implementation POLYFileManager

- (instancetype)initWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey
{
    if (self = [super init]) {
        _downloads = [[NSMutableDictionary alloc] init];
        _uploads = [[NSMutableDictionary alloc] init];
        _transferManager = [AWSS3TransferManager defaultS3TransferManager];
    }
    return self;
}

- (NSURL *)getURLForFileWithKey:(NSString *)key
{
    if (key) {
        NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseURL, key];
        return [NSURL URLWithString:url];
    } else {
        return nil;
    }
}

- (void)downloadFileWithKey:(NSString *)key
                   progress:(void (^)(CGFloat progress))progressBlock
                    success:(void (^)(NSData *))successBlock
                    failure:(void (^)(NSError *err))failureBlock
{
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = self.bucket;
    [downloadRequest setBucket:self.bucket];
    [downloadRequest setKey:key];
    downloadRequest.downloadingFileURL = [self getURLForFileWithKey:key];
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        CGFloat percentage = ((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(percentage);
        });
    };
    
    (self.downloads[key])[@"request"] = downloadRequest;
    
//    [[self.s3tm download:downloadRequest]
//     continueWithExecutor:[AWSExecutor mainThreadExecutor]
//     withBlock:^id(AWSTask *task) {
//         if (task.error){
//             if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
//                 switch (task.error.code) {
//                     case AWSS3TransferManagerErrorCancelled:
//                     case AWSS3TransferManagerErrorPaused:
//                         break;
//                         
//                     default:
//                         NSLog(@"Error: %@", task.error);
//                         break;
//                 }
//             } else {
//                 // Unknown error.
//                 NSLog(@"Error: %@", task.error);
//             }
//         }
//         
//         if (task.result) {
//             AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
//             //File downloaded successfully.
//         }
//         return nil;
//     }];
}

- (NSString *)uploadFileData:(NSData *)data
                 contentType:(NSString *)contentType
                    progress:(void (^)(CGFloat progress))progressBlock
                     success:(void (^)(BOOL finished))successBlock
                     failure:(void (^)(NSError *err))failureBlock
{
    // Build a key based off the content type
    NSString *key = [[NSUUID UUID] UUIDString];
    if ([contentType isEqualToString:@"image/jpeg"]) {
        key = [key stringByAppendingString:@".jpeg"];
    } else if ([contentType isEqualToString:@"image/webp"]) {
        key = [key stringByAppendingString:@".webp"];
    } else if ([contentType isEqualToString:@"video/mp4"]) {
        key = [key stringByAppendingString:@".mp4"];
    } else {
        NSAssert(FALSE, @"Content Type Not Accounted For In uploadFileData");
    }
    
    // write data to disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:key];
    [data writeToFile:filePath atomically:YES];
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    [uploadRequest setBucket:self.bucket];
    [uploadRequest setCacheControl:@"max-age=31536000"];
    uploadRequest.key = key;
    [uploadRequest setBody:fileURL];
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        CGFloat percentage = ((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(percentage);
        });
    };
    
    (self.uploads)[key] = uploadRequest; // add to the uploads dictionary
    
    NSMutableDictionary *uploads = self.uploads;

    [[self.transferManager upload:uploadRequest]
     continueWithExecutor:[AWSExecutor mainThreadExecutor]
     withBlock:^id(AWSTask *task) {
         [uploads removeObjectForKey:key];
         
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
             failureBlock(task.error);
         }
         
         successBlock(YES);
         
         return nil;
     }];

    return key;
}

// Part of the new SPOperationQueue implementation.

- (void)uploadVideoData:(NSData *)data
               progress:(void (^)(CGFloat progress))progressBlock
                success:(void (^)(BOOL finished, NSString *key))successBlock
                failure:(void (^)(NSError *err))failureBlock
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


- (void)uploadImage:(UIImage *)image
           progress:(void (^)(CGFloat progress))progressBlock
            success:(void (^)(BOOL finished, NSString *key))successBlock
            failure:(void (^)(NSError *err))failureBlock
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


- (void)restartUploadWithKey:(NSString *)key
{
    if ([[self.uploads allKeys] containsObject:key]) {
        [self.transferManager upload:(self.uploads)[key][@"request"]];
    }
}

- (void)cancelUploadWithKey:(NSString *)key
{
    [((AWSS3TransferManagerUploadRequest*)(self.uploads)[key][@"request"]) cancel];
    [self.uploads removeObjectForKey: key];
}

- (void)cancelAllTransfers
{
    [self.transferManager cancelAll];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Private Methods
#pragma -------------------------------------------------------------------------------------------

//- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
//{
//    void (^failureCallback)(NSError *err);
//    
//    [self removePendingBlocksForRequestWithKey: request.requestTag];
//    
//    if ([[self.downloads allKeys] containsObject: request.requestTag]) {
//        
//        failureCallback = (self.downloads)[request.requestTag][@"failure"];
//        if (failureCallback) failureCallback(error);
//        
//        [self.downloads removeObjectForKey: request.requestTag];
//        
//    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
//        
//        failureCallback = (self.uploads)[request.requestTag][@"failure"];
//        if (failureCallback) failureCallback(error);
//        
//    }
//    
//}
//
//- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
//{
////    [[POLYNetworking sharedNetwork] reportErrorWithMessage: [[NSString alloc] initWithData: response.body encoding: NSUTF8StringEncoding]];
//    
//    [self performPendingBlocksForRequestWithKey: request.requestTag];
//    
//    if ([[self.downloads allKeys] containsObject: request.requestTag]) {
//        
//        void (^successCallback)(NSData *data) = (self.downloads)[request.requestTag][@"success"];
//        successCallback([response body]);
//        
//        [self.downloads removeObjectForKey: request.requestTag];
//        
//    } else if ([[self.uploads allKeys] containsObject: request.requestTag]) {
//        
//        void (^successCallback)(BOOL finished) = (self.uploads)[request.requestTag][@"success"];
//        successCallback(YES);
//        
//        [self.uploads removeObjectForKey: request.requestTag];
//        
//    }
//    
//}

@end
