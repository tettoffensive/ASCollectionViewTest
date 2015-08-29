//
//  UIImage+WebP.m
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import "UIImage+WebP.h"

@implementation UIImage (WebP)

#pragma mark - Private methods

+ (NSData *)convertToWebP:(UIImage *)image quality:(CGFloat)quality alpha:(CGFloat)alpha preset:(WebPPreset)preset error:(NSError **)error
{
    NSLog(@"WebP Encoder Version: %@", [self version:WebPGetEncoderVersion()]);
    
    if (alpha < 1) {
        image = [self webPImage:image withAlpha:alpha];
    }
    
    CGImageRef webPImageRef = image.CGImage;
    size_t webPBytesPerRow = CGImageGetBytesPerRow(webPImageRef);
    
    size_t webPImageWidth = CGImageGetWidth(webPImageRef);
    size_t webPImageHeight = CGImageGetHeight(webPImageRef);
    
    CGDataProviderRef webPDataProviderRef = CGImageGetDataProvider(webPImageRef);
    CFDataRef webPImageDatRef = CGDataProviderCopyData(webPDataProviderRef);
    
    uint8_t *webPImageData = (uint8_t *)CFDataGetBytePtr(webPImageDatRef);
    
    WebPConfig config;
    if (!WebPConfigPreset(&config, preset, quality)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Configuration preset failed to initialize." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        
        CFRelease(webPImageDatRef);
        return nil;
    }
    
    if (!WebPValidateConfig(&config)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"One or more configuration parameters are beyond their valid ranges." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        
        CFRelease(webPImageDatRef);
        return nil;
    }
    
    WebPPicture pic;
    if (!WebPPictureInit(&pic)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to initialize structure. Version mismatch." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        
        CFRelease(webPImageDatRef);
        return nil;
    }
    pic.width = (int)webPImageWidth;
    pic.height = (int)webPImageHeight;
    pic.colorspace = WEBP_YUV420;
    
    WebPPictureImportRGBA(&pic, webPImageData, (int)webPBytesPerRow);
    WebPPictureARGBToYUVA(&pic, WEBP_YUV420);
    WebPCleanupTransparentArea(&pic);
    
    WebPMemoryWriter writer;
    WebPMemoryWriterInit(&writer);
    pic.writer = WebPMemoryWrite;
    pic.custom_ptr = &writer;
    WebPEncode(&config, &pic);
    
    NSData *webPFinalData = [NSData dataWithBytes:writer.mem length:writer.size];
    
    WebPPictureFree(&pic);
    CFRelease(webPImageDatRef);
    
    return webPFinalData;
}

+ (UIImage *)convertFromWebPData:(NSData *)imgData error:(NSError **)error
{
    NSLog(@"WebP Decoder Version: %@", [self version:WebPGetDecoderVersion()]);
    
    // `WebPGetInfo` will return image width and height
    int width = 0, height = 0;
    if(!WebPGetInfo([imgData bytes], [imgData length], &width, &height)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Header formatting error." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        return nil;
    }
    
    WebPDecoderConfig config;
    if(!WebPInitDecoderConfig(&config)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to initialize structure. Version mismatch." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        return nil;
    }
    
    config.options.no_fancy_upsampling = 1;
    config.options.bypass_filtering = 1;
    config.options.use_threads = 1;
    config.output.colorspace = MODE_RGBA;
    
    // Decode the WebP image data into a RGBA value array
    uint8_t *data = WebPDecodeRGBA([imgData bytes], [imgData length], &width, &height);
    
    // Construct UIImage from the decoded RGBA value array
    CGDataProviderRef provider = CGDataProviderCreateWithData(&config, data, config.options.scaled_width  * config.options.scaled_height * 4, NULL);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault |kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    UIImage *result = [UIImage imageWithCGImage: imageRef];
    
    // Free resources to avoid memory leaks
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
//    WebPFreeDecBuffer(&config.output);
    
    return result;
    
}

+ (UIImage *)convertFromWebP:(NSString *)filePath error:(NSError **)error
{
    NSLog(@"WebP Decoder Version: %@", [self version:WebPGetDecoderVersion()]);
    
    // If passed `filepath` is invalid, return nil to caller and log error in console
    NSError *dataError = nil;;
    NSData *imgData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&dataError];
    
    if(dataError != nil) {
        NSLog(@"imageFromWebP: error: %@", dataError.localizedDescription);
        return nil;
    } else {
        return [self convertFromWebPData: imgData error: error];
    }
    
}

#pragma mark - Synchronous methods
+ (UIImage *)imageFromWebP:(NSString *)filePath
{
    NSAssert(filePath != nil, @"imageFromWebP:filePath filePath cannot be nil");
    
    return [self convertFromWebP:filePath error:nil];
}

+ (NSData *)imageToWebP:(UIImage *)image quality:(CGFloat)quality
{
    NSAssert(image != nil, @"imageToWebP:quality: image cannot be nil");
    NSAssert(quality >= 0 && quality <= 100, @"imageToWebP:quality: quality has to be [0, 100]");
    
    return [self convertToWebP:image quality:quality alpha:1 preset:WEBP_PRESET_DEFAULT error:nil];
}

#pragma mark - Asynchronous methods
+ (void)imageFromWebP:(NSString *)filePath completionBlock:(void (^)(UIImage *result))completionBlock failureBlock:(void (^)(NSError *error))failureBlock
{
    NSAssert(filePath != nil, @"imageFromWebP:filePath:completionBlock:failureBlock filePath cannot be nil");
    NSAssert(completionBlock != nil, @"imageFromWebP:filePath:completionBlock:failureBlock completionBlock block cannot be nil");
    NSAssert(failureBlock != nil, @"imageFromWebP:filePath:completionBlock:failureBlock failureBlock block cannot be nil");
    
    // Create dispatch_queue_t for decoding WebP concurrently
    dispatch_queue_t fromWebPQueue = dispatch_queue_create("com.seanooi.ioswebp.fromwebp", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(fromWebPQueue, ^{
        
        NSError *error = nil;
        UIImage *webPImage = [self convertFromWebP:filePath error:&error];
        
        // Return results to caller on main thread in completion block is `webPImage` != nil
        // Else return in failure block
        if(webPImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(webPImage);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    });
}

+ (void)imageFromWebPData:(NSData *)imgData completionBlock:(void (^)(UIImage *))completionBlock failureBlock:(void (^)(NSError *))failureBlock
{
    NSAssert(imgData != nil, @"imageFromWebPData:imgData:completionBlock:failureBlock imgData cannot be nil");
    NSAssert(completionBlock != nil, @"imageFromWebPData:imgData:completionBlock:failureBlock completionBlock block cannot be nil");
    NSAssert(failureBlock != nil, @"imageFromWebPData:imgData:completionBlock:failureBlock failureBlock block cannot be nil");
    
    // Create dispatch_queue_t for decoding WebP concurrently
    dispatch_queue_t fromWebPQueue = dispatch_queue_create("com.seanooi.ioswebp.fromwebp", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(fromWebPQueue, ^{
        
        NSError *error = nil;
        UIImage *webPImage = [self convertFromWebPData: imgData error: &error];
        
        // Return results to caller on main thread in completion block is `webPImage` != nil
        // Else return in failure block
        if(webPImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(webPImage);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    });
}

+ (void)imageToWebP:(UIImage *)image quality:(CGFloat)quality alpha:(CGFloat)alpha preset:(WebPPreset)preset completionBlock:(void (^)(NSData *result))completionBlock failureBlock:(void (^)(NSError *error))failureBlock
{
    NSAssert(image != nil, @"imageToWebP:quality:alpha:completionBlock:failureBlock image cannot be nil");
    NSAssert(quality >= 0 && quality <= 100, @"imageToWebP:quality:alpha:completionBlock:failureBlock quality has to be [0, 100]");
    NSAssert(alpha >= 0 && alpha <= 1, @"imageToWebP:quality:alpha:completionBlock:failureBlock alpha has to be [0, 1]");
    NSAssert(completionBlock != nil, @"imageToWebP:quality:alpha:completionBlock:failureBlock completionBlock cannot be nil");
    NSAssert(completionBlock != nil, @"imageToWebP:quality:alpha:completionBlock:failureBlock failureBlock block cannot be nil");
    
    // Create dispatch_queue_t for encoding WebP concurrently
    dispatch_queue_t toWebPQueue = dispatch_queue_create("com.seanooi.ioswebp.towebp", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(toWebPQueue, ^{
        
        NSError *error = nil;
        NSData *webPFinalData = [self convertToWebP:image quality:quality alpha:alpha preset:preset error:&error];
        
        // Return results to caller on main thread in completion block is `webPFinalData` != nil
        // Else return in failure block
        if(!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(webPFinalData);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    });
}

#pragma mark - Utilities

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha
{
    NSAssert(alpha >= 0 && alpha <= 1, @"imageByApplyingAlpha:alpha alpha has to be [0, 1]");
    
    if (alpha < 1) {
        
       UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
       
       CGContextRef ctx = UIGraphicsGetCurrentContext();
       CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
       
       CGContextScaleCTM(ctx, 1, -1);
       CGContextTranslateCTM(ctx, 0, -area.size.height);
       
       CGContextSetAlpha(ctx, alpha);
       CGContextSetBlendMode(ctx, kCGBlendModeXOR);
       CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
       
       CGContextDrawImage(ctx, area, self.CGImage);
       
       UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
       
       UIGraphicsEndImageContext();
        
        return newImage;
         
    }
    else {
        return self;
    }
}

+ (UIImage *)webPImage:(UIImage *)image withAlpha:(CGFloat)alpha
{
    // CGImageAlphaInfo of images with alpha are kCGImageAlphaPremultipliedFirst
    // Convert to kCGImageAlphaPremultipliedLast to avoid gray-ish background when encoding alpha images to WebP format
    
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UInt8* pixelBuffer = malloc(height * width * 4);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(pixelBuffer, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    CGDataProviderRef dataProviderRef = CGImageGetDataProvider(imageRef);
    CFDataRef dataRef = CGDataProviderCopyData(dataProviderRef);
    
    GLubyte *pixels = (GLubyte *)CFDataGetBytePtr(dataRef);
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            NSInteger byteIndex = ((width * 4) * y) + (x * 4);
            pixelBuffer[byteIndex + 3] = pixels[byteIndex +3 ]*alpha;
        }
    }
    
    CGContextRef ctx = CGBitmapContextCreate(pixelBuffer, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGImageRef newImgRef = CGBitmapContextCreateImage(ctx);
    
    free(pixelBuffer);
    CFRelease(dataRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    
    UIImage *newImage = [UIImage imageWithCGImage:newImgRef];
    CGImageRelease(newImgRef);
    
    return newImage;
}

+ (NSString *)version:(NSInteger)version
{
    // Convert version number to hexadecimal and parse it accordingly
    // E.g: v2.5.7 is 0x020507
    
    NSString *hex = [NSString stringWithFormat:@"%06lx", (long)version];
    NSMutableArray *array = [NSMutableArray array];
    for (int x = 0; x < [hex length]; x += 2) {
        [array addObject:@([[hex substringWithRange:NSMakeRange(x, 2)] integerValue])];
    }
    
    return [array componentsJoinedByString:@"."];
}

#pragma mark - Error statuses

+ (NSString *)statusForVP8Code:(VP8StatusCode)code
{
    NSString *errorString;
    switch (code) {
        case VP8_STATUS_OUT_OF_MEMORY:
            errorString = @"OUT_OF_MEMORY";
            break;
        case VP8_STATUS_INVALID_PARAM:
            errorString = @"INVALID_PARAM";
            break;
        case VP8_STATUS_BITSTREAM_ERROR:
            errorString = @"BITSTREAM_ERROR";
            break;
        case VP8_STATUS_UNSUPPORTED_FEATURE:
            errorString = @"UNSUPPORTED_FEATURE";
            break;
        case VP8_STATUS_SUSPENDED:
            errorString = @"SUSPENDED";
            break;
        case VP8_STATUS_USER_ABORT:
            errorString = @"USER_ABORT";
            break;
        case VP8_STATUS_NOT_ENOUGH_DATA:
            errorString = @"NOT_ENOUGH_DATA";
            break;
        default:
            errorString = @"UNEXPECTED_ERROR";
            break;
    }
    return errorString;
}
@end