//
//  POLYVideoManager.m
//  Swipe
//
//  Created by Addison Hardy on 11/25/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

#import "POLYVideoManager.h"
#import "POLYFileManager.h"

#import <AFNetworking/AFHTTPRequestOperation.h>

@implementation POLYVideoManager

+ (instancetype)sharedInstance
{
    
    static POLYVideoManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)cachePathForKey:(NSString *)key
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    if (paths.count > 0) {
        
        return [paths[0] stringByAppendingPathComponent: key];
        
    } else {
        
        return nil;
        
    }
    
}

+ (BOOL)cacheVideoWithKey:(NSString *)key andData:(NSData *)data {
    
    NSError *error;
    NSString *path = [POLYVideoManager cachePathForKey: key];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path]) {
        [data writeToFile: path options: 0 error: &error];
    }
    
    if (error) {
        NSLog(@"Error writing video file to disk: %@", error.debugDescription);
        return NO;
    }
    
    return YES;
    
}

+ (BOOL)checkIfPathExists:(NSString *)path {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: path]) {
        return YES;
    }
    
    return NO;
    
}

- (void)discardVideoWithKey:(NSString *)key
{
    NSError *error;
    NSString *path = [POLYVideoManager cachePathForKey: key];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: path]) {
        [[NSFileManager defaultManager] removeItemAtPath: path error: &error];
    }
    
    if (error) {
        NSLog(@"Error deleting cached video file: %@", error.debugDescription);
    }
}

- (void)downloadVideoWithKey:(NSString *)key usingBlock:(void (^)(NSString *))complete
{
    NSString *path = [POLYVideoManager cachePathForKey: key];
    
    if ([POLYVideoManager checkIfPathExists: path]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) complete(path);
        });
        
    } else {
    
        NSURL *url = [self.fileManager getURLForFileWithKey: key];
        
        if (url) {
                
    //        NSDate *now = [NSDate new];
            NSURLRequest *request = [NSURLRequest requestWithURL: url];
            
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
            requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject: @"video/mp4"];
            
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSData *data = [NSData dataWithData: responseObject];
                
    //            NSLog(@"%.2fmb mp4 downloaded from %@ in %f seconds", (CGFloat)data.length / 1000000, url.host, [now timeIntervalSinceNow] * -1);
                
                BOOL success = [POLYVideoManager cacheVideoWithKey: key andData: data];
                
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) complete(path);
                    });
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                //NSLog(@"AFHTTPRequest file download error: %@", error.debugDescription);
                
            }];
            
            [requestOperation start];
            
        }
        
    }
    
}

@end
