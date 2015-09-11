//
//  POLYActivityIndicator.h
//  loading
//
//  Created by Dana Shakiba on 9/8/15.
//  Copyright © 2015 swipe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POLYActivityIndicator : UIView

- (void)start;
- (void)stopWithCompletion:(BOOL)showCompletion;

@end
