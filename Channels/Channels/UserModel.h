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
@property (readonly) NSString *username;

+ (instancetype)currentUser;

// Methods for current user session
+ (void)registerWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email success:(void(^)(UserModel *userModel))success andFailure:(void(^)(NSError *error))failure;
+ (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password success:(void(^)(UserModel *userModel))success andFailure:(void(^)(NSError *error))failure;
+ (BOOL)isLoggedIn;

- (void)loginWithAccessToken:(NSString *)accessToken;
- (void)logout;
- (NSString *)accessToken;
- (void)fetchCurrentUserInfo;

@end
