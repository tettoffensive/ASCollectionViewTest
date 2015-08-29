//
//  POLYUtils.m
//  Tagthis
//
//  Created by Marwan on 8/14/13.
//  Copyright (c) 2013 Addison Hardy. All rights reserved.
//

#import "POLYUtils.h"

#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#include <sys/types.h>
#include <sys/sysctl.h>

//#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
//#import <RHAddressBook/RHAddressBook.h>
//#import <RHAddressBook/RHPerson.h>
#import "UIImage+WebP.h"

@implementation POLYUtils

// Device

+ (NSString *)deviceIdentifier {
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
    
}

+ (BOOL)deviceUsesLowResolutionCamera {
    
    NSString *device = [POLYUtils deviceIdentifier];
    
    if ([device rangeOfString: @"iPhone"].location != NSNotFound) {
        NSString *model = [device stringByReplacingOccurrencesOfString: @"iPhone" withString: @""];
        int family = [[model substringToIndex: 1] intValue];
        if (family < 6) {
            return YES;
        }
    }
    
    return NO;
    
}

// Filesystem

+ (NSString *)documentPathForFilename:(NSString *)filename {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex: 0];
    NSString *path = [documents stringByAppendingPathComponent: filename];
    
    return path;
    
}

// Helpers

+ (NSString *)formatLargeNumber:(int)number {
    NSString *numberString = @"";
    if (number < 10000) {
        numberString = [NSString stringWithFormat:@"%d",number];
    } else if (number < 1000000) {
        CGFloat n = number / 1000;
        numberString = [NSString stringWithFormat:@"%0.0fK",n];
    } else if (number < 10000000) {
        CGFloat n = number / 1000000.0f;
        numberString = [NSString stringWithFormat:@"%0.1fM",n];
    } else {
        CGFloat n = number / 1000000;
        numberString = [NSString stringWithFormat:@"%0.0fM",n];
    }
    return numberString;
}

+ (CGFloat)keyboardHeight:(NSNotification*)notification forView:(UIView*)view {
    
    NSDictionary *info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboard;
    [value getValue:&keyboard];
    keyboard = [view convertRect: keyboard fromView: 0];
    return keyboard.size.height;
    
}

+ (NSString *)randomIdentifierWithLength:(int)length {
    
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    int possibilities = (int)[alphabet length];
    
    NSMutableString *identifer = [NSMutableString stringWithCapacity: length];
    
    for (NSUInteger i = 0U; i < length; i++) {
        u_int32_t random = arc4random() % possibilities;
        unichar character = [alphabet characterAtIndex: random];
        [identifer appendFormat: @"%C", character];
    }
    
    return [identifer copy];
    
}

+ (NSString *)sha1:(NSString*)input {

    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;

}

// Images

+ (NSData *)dataFromRedrawnImage:(UIImage *)image {
    
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [image drawInRect:rect];
    UIImage *redrawn = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(redrawn, 0.85);
    UIGraphicsEndImageContext();

    return imageData;
    
}

+ (UIImage *)imageResizedForThumbnail:(UIImage *)image {
    
    CGFloat size = 88.0;
    
    CGSize scaledSize = CGSizeMake(size, (image.size.height * size) / image.size.width);
    
    UIGraphicsBeginImageContext(scaledSize);
    
    [image drawInRect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height + 1.0)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (UIImage *)imageResizedForUpload:(UIImage *)image {
    
    CGFloat size = 1080.0;
    
    CGSize scaledSize = CGSizeMake(size, (image.size.height * size) / image.size.width);
    
    UIGraphicsBeginImageContext(scaledSize);
    
    [image drawInRect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height + 1.0)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (NSString *)imageProcessedForUpload:(UIImage *)image withCompletion:(void (^)(NSData *, NSString *))complete {
    
    __block NSString *identifier = [POLYUtils randomIdentifierWithLength: 8];
    
    [UIImage imageToWebP: image quality: 85 alpha: 0.99 preset: WEBP_PRESET_PHOTO completionBlock:^(NSData *result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"Size in webP: %dkb", (int)result.length / 1000);
            if (complete) complete(result, identifier);
        });
        
    } failureBlock:^(NSError *error) {
        
        NSLog(@"Error converting to webP: %@", error.debugDescription);
        
    }];
    
    return identifier;
    
}

+ (void)imageFromWebPData:(NSData *)data withCompletion:(void (^)(UIImage *))complete {
    
    [UIImage imageFromWebPData: data completionBlock:^(UIImage *result) {
        
        if (result) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(result);
            });
            
        } else {
            
            NSLog(@"Error converting from webp: result is nil");
            
        }
        
    } failureBlock:^(NSError *error) {
        
        NSLog(@"Error converting from webp: %@", error.debugDescription);
        
    }];
    
}

+ (void)logSizeForImage:(UIImage *)image withName:(NSString *)name
{
    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    NSLog(@"Image [%@] size: %dkb", name, (int)data.length / 1000);
    data = nil;
    
}

+ (UIImage *)imageResizedAtWidth:(CGFloat)width image:(UIImage *)image
{
    
    CGFloat size = width;
    
    CGSize scaledSize = CGSizeMake(size, (image.size.height * size) / image.size.width);
    
    UIGraphicsBeginImageContext(scaledSize);
    
    [image drawInRect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height + 1.0)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

@end

// Debugger

void __POLYDebug(const char *fileName, int lineNumber, NSString *fmt, ...)
{
#if CONFIG_ENABLE_LOGS
    va_list args;
    va_start(args, fmt);
    NSString *logMsg = [[NSString alloc] initWithFormat:fmt arguments:args];
    __POLYDebugPrint(fileName, lineNumber, logMsg);
    va_end(args);
#endif
}

void __POLYDebugPrint(const char *fileName, int lineNumber, NSString *logMsg)
{
    static NSDateFormatter *debugFormatter = nil;
    debugFormatter = [[NSDateFormatter alloc] init];
    [debugFormatter setDateFormat:@"yyyyMMdd.HH:mm:ss"];
    NSString *filePath  = [[NSString alloc] initWithUTF8String:fileName];
    fprintf(stdout, "%.f %s:%d - %s\n", [NSDate timeIntervalSinceReferenceDate], [[filePath lastPathComponent] UTF8String], lineNumber, [logMsg UTF8String]);
}

void POLYDispatch(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

void POLYDispatchAfter(NSTimeInterval seconds, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void POLYDispatchBackground(dispatch_block_t block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void POLYDispatchBackgroundAfter(NSTimeInterval seconds, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

double screenWidth()
{
    return [UIScreen mainScreen].bounds.size.width;
}

double screenHeight()
{
    return [UIScreen mainScreen].bounds.size.height;
}

CGSize resizeWidthWhilePreservingAspectRatio(CGSize currentSize, CGFloat newSize)
{
    CGSize size     = CGSizeZero;
    CGFloat ratio     = (newSize/currentSize.width);
    size.width      = currentSize.width*ratio;
    size.height     = currentSize.height*ratio;
    
    return size;
}

CGSize resizeHeightWhilePreservingAspectRatio(CGSize currentSize, CGFloat newSize)
{
    CGSize size     = CGSizeZero;
    CGFloat ratio     = (newSize/currentSize.height);
    size.width      = currentSize.width*ratio;
    size.height     = currentSize.height*ratio;
    
    return size;
}

CGFloat saturate(CGFloat x)
{
    return MAX(0, MIN(1, x));
}

CGFloat smoothstep(CGFloat edge0, CGFloat edge1, CGFloat x)
{
    // Scale, bias and saturate x to 0..1 range
    x = saturate((x - edge0)/(edge1 - edge0));
    // Evaluate polynomial
    return x*x*(3 - 2*x);
}

CGFloat smootherstep(CGFloat edge0, CGFloat edge1, CGFloat x)
{
    // Scale, and clamp x to 0..1 range
    x = MIN(MAX((x - edge0)/(edge1 - edge0), 0.0), 1.0);
    // Evaluate polynomial
    return x*x*x*(x*(x*6 - 15) + 10);
}

CGFloat lerp( CGFloat a, CGFloat b, CGFloat fraction )
{
    return a + ( fraction * ( b - a ) );
}

CGFloat fit(CGFloat s, CGFloat oldmin, CGFloat oldmax, CGFloat newmin, CGFloat newmax)
{
    return (newmin + (s-oldmin)*(newmax-newmin)/(oldmax-oldmin));
}

CGFloat degreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat radiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

UIImage *takeScreenshotOfView(UIView *view)
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

BOOL is_iphone5()
{
    return (screenHeight() == 569.0f) ? YES : NO;
}

