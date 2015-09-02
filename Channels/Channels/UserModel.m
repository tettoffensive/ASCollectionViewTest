//
//  UserModel.m
//  Channels
//
//  Created by Ryan Nelwan on 8/31/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (instancetype)currentUser
{
    static UserModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Preliminary
#pragma ------------------------------------------------------------------------------------------------------

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"userID": @"user_id"};
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Api - Current User (only call on these set of methods for current user session)
#pragma ------------------------------------------------------------------------------------------------------

- (void)login
{
    
}

- (void)isLoggedIn
{
    
}

- (NSString *)accessToken
{
    return nil;
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
