//
//  Utils.h
//  Tagthis
//
//  Created by Marwan on 8/14/13.
//  Copyright (c) 2013 Addison Hardy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Utils : NSObject

// Device

+ (NSString *)deviceIdentifier;
+ (BOOL)deviceUsesLowResolutionCamera;

// Filesystem

+ (NSString *)documentPathForFilename:(NSString *)filename;

// Helpers

+ (NSString *)formatLargeNumber:(int)number;
+ (CGFloat)keyboardHeight:(NSNotification*)notification forView:(UIView*)view;
+ (NSString *)randomIdentifierWithLength:(int)length;
+ (NSString *)sha1:(NSString*)input;

// Images

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
#define SPLog(format...) __SPDebug(__FILE__, __LINE__, format)
void __SPDebug(const char *fileName, int lineNumber, NSString *fmt, ...);
void __SPDebugPrint(const char *fileName, int lineNumber, NSString *logMsg);
void SPDispatch(dispatch_block_t block);
void SPDispatchAfter(NSTimeInterval seconds, dispatch_block_t block);
double screenWidth();
double screenHeight();
void animateEaseInOut(CGFloat duration, void (^animation)(), void (^completion)());
CGSize resizeWidthWhilePreservingAspectRatio(CGSize currentSize, CGFloat newSize);
CGSize resizeHeightWhilePreservingAspectRatio(CGSize currentSize, CGFloat newSize);
CGFloat saturate(CGFloat x);
CGFloat smoothstep(CGFloat edge0, CGFloat edge1, CGFloat x);
CGFloat smootherstep(CGFloat edge0, CGFloat edge1, CGFloat x);
CGFloat lerp( CGFloat a, CGFloat b, CGFloat fraction );
CGFloat fit(CGFloat s, CGFloat oldmin, CGFloat oldmax, CGFloat newmin, CGFloat newmax);
CGFloat degreesToRadians(CGFloat degrees);
CGFloat radiansToDegrees(CGFloat radians);
UIImage *takeScreenshotOfView(UIView *view);
BOOL is_iphone5();