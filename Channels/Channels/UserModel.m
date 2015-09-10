//
//  UserModel.m
//  Channels
//
//  Created by Ryan Nelwan on 8/31/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "UserModel.h"
#import "ChannelsNetworking.h"

@implementation UserModel

static UserModel *__currentUser = nil;

+ (instancetype)currentUser
{
    if (!__currentUser) __currentUser = [[UserModel alloc] initForCurrentUser];
    return __currentUser;
}

- (instancetype)initForCurrentUser
{
    if (self == [super init]) {
        self->_userID = [UserModel getPropertyForKey:@"userModelUserID"];
        self->_username = [UserModel getPropertyForKey:@"userModelUsername"];
    }
    return self;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Preliminary
#pragma ------------------------------------------------------------------------------------------------------

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"userID": @"id", @"username":@"username"};
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Api - Current User (only call on these set of methods for current user session)
#pragma ------------------------------------------------------------------------------------------------------


+ (void)registerWithUsername:(NSString *)username password:(NSString *)password andEmail:(NSString *)email success:(void(^)(UserModel *userModel))success andFailure:(void(^)(NSError *error))failure
{
    [[ChannelsNetworking sharedInstance] userRegisterWithUsername:username password:password andEmail:email success:^{
        
        [UserModel loginWithUsername:username andPassword:password success:^(UserModel *userModel) {
            
            if (success) success(userModel);
            
        } andFailure:^(NSError *error) {
            
            if (failure) failure(error);
            
        }];
        
    } andFailure:^(NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

+ (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password success:(void(^)(UserModel *userModel))success andFailure:(void(^)(NSError *error))failure
{
    [[ChannelsNetworking sharedInstance] userLoginWithUsername:username andPassword:password success:^(NSDictionary *responseData){
        
        NSString *accessToken = [responseData objectForKey:@"access_token"];
        [UserModel setProperty:accessToken forKey:@"userModelAccessToken"];
        [UserModel setProperty:@(YES) forKey:@"userModelIsLoggedIn"];
        
        UserModel *userModel = [UserModel modelWithDictionary:[responseData objectForKey:@"user"]];
        [UserModel setProperty:userModel.userID forKey:@"userModelUserID"];
        [UserModel setProperty:userModel.username forKey:@"userModelUsername"];
        
        if (success) success([UserModel currentUser]);
        
    } andFailure:^(NSError *error) {
        
        if (failure) failure(error);
        
    }];
}

- (void)logout
{
    [UserModel setProperty:@"" forKey:@"userModelAccessToken"];
    [UserModel setProperty:@(NO) forKey:@"userModelIsLoggedIn"];
    
    __currentUser = nil;
}

+ (BOOL)isLoggedIn
{
    return [[UserModel getPropertyForKey:@"userModelIsLoggedIn"] boolValue];
}

- (NSString *)accessToken
{
    return [UserModel getPropertyForKey:@"userModelAccessToken"];
}

- (void)fetchCurrentUserInfo
{
    if (![UserModel isLoggedIn]) {
        return;
    }
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Helpers
#pragma ------------------------------------------------------------------------------------------------------

+ (id)getPropertyForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey: key];
}

+ (void)removeKey:(NSString *)key {
    if (key) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey: key];
    }
}

+ (void)setProperty:(id)property forKey:(NSString *)key {
    if ((property != nil) && (key != nil)) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: property forKey: key];
    }
}

@end
