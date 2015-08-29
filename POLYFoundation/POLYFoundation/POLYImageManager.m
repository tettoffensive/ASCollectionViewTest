//
//  POLYImageManager.m
//  Tag
//
//  Created by Addison Hardy on 6/10/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

#import "POLYImageManager.h"

#import "POLYFileManager.h"

#import <AFNetworking/AFHTTPRequestOperation.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>

@implementation POLYImageManager

+ (instancetype)sharedInstance
{
    
    static POLYImageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
    
}

- (void)downloadImageWithKey:(NSString *)key cacheToDisk:(BOOL)diskCache withProgress:(void (^)(CGFloat percentage))progress usingBlock:(void (^)(BOOL finished, NSString *key, UIImage *image))complete
{
    [self downloadImageWithKey:key cacheToDisk:diskCache withProgress:progress usingBlock:complete failure:nil];
}

- (void)downloadImageWithKey:(NSString *)key cacheToDisk:(BOOL)diskCache withProgress:(void (^)(CGFloat percentage))progress usingBlock:(void (^)(BOOL finished, NSString *key, UIImage *image))complete failure:(void(^)(NSError *error))failure
{
    
    NSURL *url = [self.fileManager getURLForFileWithKey: key];
    
    if (url) {
        
        if ([key rangeOfString: @".jpeg"].location == NSNotFound) {
            
            // Uncomment this line to flush the cache for each key
            // [[SDImageCache sharedImageCache] removeImageForKey: key fromDisk: YES];
            
            [[SDImageCache sharedImageCache] queryDiskCacheForKey: key done:^(UIImage *image, SDImageCacheType cacheType) {
                
                if (image) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) complete(YES, key, image);
                    });
                    
                    [[SDImageCache sharedImageCache] removeImageForKey: key fromDisk: NO withCompletion:^{
                        //
                    }];
                    
                } else {
        
                    // NSDate *now = [NSDate new];
                    NSURLRequest *request = [NSURLRequest requestWithURL: url];
                    
                    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
                    requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject: @"image/webp"];
                    
                    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        if (responseObject) {
                        
                        // NSLog(@"WebP download from %@ took %f seconds", url.host, [now timeIntervalSinceNow] * -1);
                        
                            NSData *data = [NSData dataWithData: responseObject];
             
                            [POLYUtils imageFromWebPData: data withCompletion:^(UIImage *image) {
                                
                                if (image) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (complete) complete(YES, key, image);
                                    });
                                    
                                    if (diskCache) {
                                        
                                        POLYDispatchBackgroundAfter(0.01, ^{
                                            NSData *imageData = [POLYUtils dataFromRedrawnImage: image];
                                            [[SDImageCache sharedImageCache] storeImage: image recalculateFromImage: NO imageData: imageData forKey: key toDisk: YES];
                                        });
                                        
                                    }
                                    
                                }
                                
                            }];
             
                            
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        //NSLog(@"AFHTTPRequest file download error: %@", error.debugDescription);
                        
                    }];
                    
                    [requestOperation start];
             
                }
                
            }];
        
        } else {
        
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL: url options: (SDWebImageDownloaderContinueInBackground | SDWebImageDownloaderLowPriority | SDWebImageDownloaderProgressiveDownload | SDWebImageDownloaderUseNSURLCache) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress) progress((CGFloat)receivedSize / (CGFloat)expectedSize);
                });
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                // error = [NSError errorWithDomain:@"NSHipsterErrorDomain" code:-57 userInfo:@{}];
                
                if (!error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) complete(finished, key, image);
                    });
                    
                } else if (error && failure) {
                    
                    if (failure) failure(error);
                    
                }
                
            }];
            
        }
        
    }
    
}

@end
