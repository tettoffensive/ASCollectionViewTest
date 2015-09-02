//
//  POLYUtils.h
//  Tagthis
//
//  Created by Marwan on 8/14/13.
//  Copyright (c) 2013 Addison Hardy. All rights reserved.
//

@import UIKit;

@interface POLYUtils : NSObject

// Device
+ (NSString *)deviceIdentifier;
+ (BOOL)deviceUsesLowResolutionCamera;

// Filesystem
+ (NSString *)documentPathForFilename:(NSString *)filename;

// Helpers
+ (NSString *)formatLargeNumber:(NSInteger)number;
+ (CGFloat)keyboardHeight:(NSNotification*)notification forView:(UIView*)view;
+ (NSString *)randomIdentifierWithLength:(NSInteger)length;
+ (NSString *)sha1:(NSString*)input;

// Images
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (NSData *)dataFromRedrawnImage:(UIImage *)image;
+ (UIImage *)imageResizedAtWidth:(CGFloat)width image:(UIImage *)image;
+ (UIImage *)imageResizedForThumbnail:(UIImage *)image;
+ (UIImage *)imageResizedForUpload:(UIImage *)image;
+ (NSString *)imageProcessedForUpload:(UIImage *)image withCompletion:(void (^)(NSData *data, NSString *conversionID))complete;
+ (void)imageFromWebPData:(NSData *)data withCompletion:(void (^)(UIImage *image))complete;
+ (void)logSizeForImage:(UIImage *)image withName:(NSString *)name;

@end

// Debugger

/**
 *  Please use this method for logging into the console.
 *  It'll be easier to turn off logs when deploying to production.
 */
#define POLYLog(format...) __POLYDebug(__FILE__, __LINE__, format)
extern void __POLYDebug(const char *fileName, int lineNumber, NSString *fmt, ...);
extern void __POLYDebugPrint(const char *fileName, int lineNumber, NSString *logMsg);

extern void POLYDispatch(dispatch_block_t block);
extern void POLYDispatchAfter(NSTimeInterval seconds, dispatch_block_t block);
extern void POLYDispatchBackground(dispatch_block_t block);
extern void POLYDispatchBackgroundAfter(NSTimeInterval seconds, dispatch_block_t block);

extern double screenWidth();
extern double screenHeight();

extern CGSize resizeWidthWhilePreservingAspectRatio(CGSize currentSize, CGFloat newSize);
extern CGSize resizeHeightWhilePreservingAspectRatio(CGSize currentSize, CGFloat newSize);
extern CGFloat saturate(CGFloat x);
extern CGFloat smoothstep(CGFloat edge0, CGFloat edge1, CGFloat x);
extern CGFloat smootherstep(CGFloat edge0, CGFloat edge1, CGFloat x);
extern CGFloat lerp( CGFloat a, CGFloat b, CGFloat fraction );
extern CGFloat fit(CGFloat s, CGFloat oldmin, CGFloat oldmax, CGFloat newmin, CGFloat newmax);
extern CGFloat degreesToRadians(CGFloat degrees);
extern CGFloat radiansToDegrees(CGFloat radians);
extern UIImage *takeScreenshotOfView(UIView *view);
extern BOOL is_iphone5();
