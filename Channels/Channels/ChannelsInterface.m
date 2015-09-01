//
//  ChannelsInterface.m
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelsInterface.h"

@implementation ChannelsInterface

+ (UIColor *)navigationBarColor
{
    return [self colorFromHexString:@"#191926"];
}

+ (UIColor *)viewBackgroundColor
{
    return [self colorFromHexString:@"#191926"];
}

+ (UIColor *)channelsGreenColor
{
    return [self colorFromHexString:@"#2ecc71"];
}

+ (UIFont *)regularFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Geomanist-Regular" size:fontSize];
}

+ (UIFont *)extraLightFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Geomanist-ExtraLight" size:fontSize];
}

+ (UIFont *)lightFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Geomanist-Light" size:fontSize];
}

+ (UIFont *)thinFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Geomanist-Thin" size:fontSize];
}

+ (UIFont *)mediumFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Geomanist-Medium" size:fontSize];
}

+ (UIFont *)boldFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Geomanist-Bold" size:fontSize];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
