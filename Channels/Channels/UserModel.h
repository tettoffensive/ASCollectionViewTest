//
//  UserModel.h
//  Channels
//
//  Created by Ryan Nelwan on 8/31/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface UserModel : MTLModel<MTLJSONSerializing>

@property (readonly) NSInteger userID;

+ (instancetype)currentUser;
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

// Methods for current user session

- (void)login;
- (void)isLoggedIn;
- (NSString *)accessToken;

@end
