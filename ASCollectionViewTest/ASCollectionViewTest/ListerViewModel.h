//
//  ListerViewModel.h
//
//  Created by Stuart Tett on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ViewModel.h"
#import "ValueObject.h"

@class ItemInfo;

@interface ListerViewModel : ViewModel

@property (nonatomic, copy, readonly) NSArray<ItemInfo*> *itemList;

- (void)updateList;

@end

@interface ItemInfo : ValueObject

@property (readonly) NSString      *title;
@property (readonly) NSURL         *thumbnailURL;
@property (readonly) BOOL           isTrending;
@property (readonly) NSString      *lastUpdatedString;
@property (readonly) BOOL           newPosts;

@end
