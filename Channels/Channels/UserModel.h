//
//  UserModel.h
//  Channels
//
//  Created by Ryan Nelwan on 8/31/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseModel.h"

@interface UserModel : BaseModel

@property (readonly) NSInteger userID;

+ (instancetype)currentUser;

// Methods for current user session

- (void)login;
- (void)isLoggedIn;
- (NSString *)accessToken;

@end
