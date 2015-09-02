//
//  POLYViewModel.h
//  POLYFoundation
//
//  Created by Stuart Tett on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POLYViewModel : NSObject
/*!
 *  List of properties to be bound (via KVOController) to the View
 */
@property (nonatomic, readonly, nonnull) NSArray<NSString *> *keys;

@end
