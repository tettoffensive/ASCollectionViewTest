//
//  ChannelsInterface.h
//  Channels
//
//  Created by Dana Shakiba on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface ChannelsInterface : NSObject

+ (UIColor *)navigationBarColor;
+ (UIColor *)viewBackgroundColor;
+ (UIColor *)channelsGreenColor;

+ (UIFont *)regularFontOfSize:(CGFloat)fontSize;
+ (UIFont *)extraLightFontOfSize:(CGFloat)fontSize;
+ (UIFont *)lightFontOfSize:(CGFloat)fontSize;
+ (UIFont *)thinFontOfSize:(CGFloat)fontSize;
+ (UIFont *)mediumFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldFontOfSize:(CGFloat)fontSize;

@end
