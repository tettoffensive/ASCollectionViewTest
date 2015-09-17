//
//  BaseModel.h
//
//  Created by Ryan Nelwan on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface BaseModel : MTLModel<MTLJSONSerializing>
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
@end
