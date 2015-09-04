//
//  LoginViewController.m
//  Channels
//
//  Created by Ryan Nelwan on 9/4/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "LoginViewController.h"
#import "UserModel.h"

@interface LoginViewController()

@property (nonatomic) UIView *loginContainerView;
@property (nonatomic) UIView *registerContainerView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:self.loginContainerView];
}

- (UIView *)loginContainerView
{
    return !_loginContainerView ? _loginContainerView =
    ({
        UIView *view = [[UIView alloc] init];
        view;
    }) : _loginContainerView;
}

- (UIView *)registerContainerView
{
    return !_registerContainerView ? _registerContainerView =
    ({
        UIView *view = [[UIView alloc] init];
        view;
    }) : _registerContainerView;
}

@end
