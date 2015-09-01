//
//  POLYUploadManager.h
//  Tag
//
//  Created by Addison Hardy on 1/17/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

@import UIKit;

@import AWSS3;

@interface POLYFileManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAccessKey:(NSString *)accessKey
                    withSecretKey:(NSString *)secretKey NS_DESIGNATED_INITIALIZER;

/*!
 *  S3 Bucket
 */
@property (nonatomic, strong) NSString *bucket;
/*!
 *  S3 Region. Defaults to AWSRegionUSWest2
 */
@property (nonatomic)     AWSRegionType region;
/*!
 *  Subpath inside S3 Bucket - @"test/test/.../test"
 */
@property (nonatomic, strong) NSString *subpath;
/*!
 *  Base URL For Uploads. Defaults to @"http://cdn.joinswipe.com"
 */
@property (nonatomic, strong) NSString *baseURLString;

/*!
 *  Download a generic file from S3 with a unique key
 *
 *  @param key           A key generated when the app uploaded the file originally
 *  @param progressBlock A block that executes as the file downloads periodically
 *  @param successBlock  A block with the local file path of the downloaded file
 *  @param failureBlock  A block that executes when the file fails to download
 *
 *  @return A task that will be completed after block has run. If block returns a AWSTask, then the task returned from this method will not be completed until that task is completed.
 */
- (AWSTask *)downloadFileWithKey:(NSString *)key
                   progress:(void (^)(CGFloat progress))progressBlock
                    success:(void (^)(NSURL *))successBlock
                    failure:(void (^)(NSError *err))failureBlock;
/*!
 *  Download an image file from S3 with a unique key
 *
 *  @param key           A key generated when the app uploaded the file originally
 *  @param progressBlock A block that executes as the file downloads periodically
 *  @param successBlock  A block with the UIImage representation of the download
 *  @param failureBlock  A block that executes when the file fails to download
 *
 *  @return A task that will be completed after block has run. If block returns a AWSTask, then the task returned from this method will not be completed until that task is completed.
 */
- (AWSTask *)downloadImageWithKey:(NSString *)key
                    progress:(void (^)(CGFloat progress))progressBlock
                     success:(void (^)(UIImage *image))successBlock
                     failure:(void (^)(NSError *err))failureBlock;
/*!
 *  Upload a generic file to S3
 *
 *  @param data          data to be uploaded
 *  @param contentType   mime-type of the file
 *  @param progressBlock A block that executes as the file downloads periodically
 *  @param successBlock  A block that contains the unique key of the file uploaded
 *  @param failureBlock  A block that executes when the file fails to download
 *
 *  @return A task that will be completed after block has run. If block returns a AWSTask, then the task returned from this method will not be completed until that task is completed.
 */
- (AWSTask *)uploadFileData:(NSData *)data
       withContentType:(NSString *)contentType
              progress:(void (^)(CGFloat progress))progressBlock
               success:(void (^)(BOOL finished, NSString *key))successBlock
               failure:(void (^)(NSError *err))failureBlock;
/*!
 *  Upload an image as a JPEG file to S3
 *
 *  @param data          data to be uploaded
 *  @param contentType   mime-type of the file
 *  @param progressBlock A block that executes as the file downloads periodically
 *  @param successBlock  A block that contains the unique key of the file uploaded
 *  @param failureBlock  A block that executes when the file fails to download
 *
 *  @return A task that will be completed after block has run. If block returns a AWSTask, then the task returned from this method will not be completed until that task is completed.
 */
- (AWSTask *)uploadImage:(UIImage *)image
           progress:(void (^)(CGFloat progress))progressBlock
            success:(void (^)(BOOL finished, NSString *key))successBlock
            failure:(void (^)(NSError *err))failureBlock;
/*!
 *  Upload a video file as an MP4 to S3
 *
 *  @param data          data to be uploaded (should be an mp4)
 *  @param contentType   mime-type of the file
 *  @param progressBlock A block that executes as the file downloads periodically
 *  @param successBlock  A block that contains the unique key of the file uploaded
 *  @param failureBlock  A block that executes when the file fails to download
 *
 *  @return A task that will be completed after block has run. If block returns a AWSTask, then the task returned from this method will not be completed until that task is completed.
 */
- (AWSTask *)uploadVideoData:(NSData *)data
               progress:(void (^)(CGFloat progress))progressBlock
                success:(void (^)(BOOL finished, NSString *key))successBlock
                failure:(void (^)(NSError *err))failureBlock;

- (AWSTask *)pauseUploadWithKey:(NSString *)key;
- (AWSTask *)restartUploadWithKey:(NSString *)key;
- (AWSTask *)cancelUploadWithKey:(NSString *)key;

- (AWSTask *)pauseDownloadWithKey:(NSString *)key;
- (AWSTask *)restartDownloadWithKey:(NSString *)key;
- (AWSTask *)cancelDownloadWithKey:(NSString *)key;

- (AWSTask *)pauseAllTransfers;
- (AWSTask *)resumeAllTransfers;
- (AWSTask *)cancelAllTransfers;

/*!
 *  Constructs the URL used to represent a given asset uploaded to S3
 *
 *  @param key key generated by upload method
 *
 *  @return URL representation of asset using baseURLString and key
 */
- (NSURL *)getURLForFileWithKey:(NSString *)key;

@end
