//
//  BaseModel.m
//  Channels
//
//  Created by Ryan Nelwan on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{};
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
    NSError *error = nil;
    id userModel = [MTLJSONAdapter modelOfClass:self.class fromJSONDictionary:dictionary error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
    }
    
    return userModel;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    self = [super initWithDictionary:dictionary error:error];
    if (self == nil) return nil;
    return self;
}

@end
