//
//  LoginViewController.m
//  Channels
//
//  Created by Ryan Nelwan on 9/4/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "LoginViewController.h"
#import "ChannelsAppDelegate.h"

#import "ChannelsNetworking.h"
#import "UserModel.h"
#import "ChannelsInterface.h"

#define LoginViewPlaceHolderUsername @"Username"
#define LoginViewPlaceHolderPassword @"Password"
#define LoginViewPlaceHolderEmail @"Email"

@interface LoginViewController()<UITextFieldDelegate>

@property (nonatomic) UIButton *switchButton;

@property (nonatomic) UIView *loginContainerView;
@property (nonatomic) UIButton *loginButton;
@property (nonatomic) UITextField *loginUsernameTextField;
@property (nonatomic) UITextField *loginPasswordTextField;

@property (nonatomic) UIView *registerContainerView;
@property (nonatomic) UIButton *registerButton;
@property (nonatomic) UITextField *registerUsernameTextField;
@property (nonatomic) UITextField *registerPasswordTextField;
@property (nonatomic) UITextField *registerEmailTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"#191926"]];
    
    [self.view addSubview:self.loginContainerView];
    [self.view addSubview:self.registerContainerView];
    self.registerContainerView.hidden = YES;
    
    [self.view addSubview:self.switchButton];
    [self.switchButton centerAlign];
    [self.switchButton setY:CGRectGetMaxY(self.registerContainerView.frame)];
    [self.switchButton moveByY:20.0f];
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - UI Builders
#pragma ------------------------------------------------------------------------------------------------------

- (UIButton *)switchButton
{
    return !_switchButton ? _switchButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
        button.backgroundColor = [UIColor colorWithHexString:@"#2d6fcc"];
        button.layer.cornerRadius = 3.0f;
        [button setTitle:@"Switch to register form" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressHandler:) forControlEvents:UIControlEventTouchUpInside];
        [[button titleLabel] setFont:[ChannelsInterface mediumFontOfSize:12]];
        button;
    }) :_switchButton;
}

- (UIView *)loginContainerView
{
    return !_loginContainerView ? _loginContainerView =
    ({
        CGFloat margin = 20.0f;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(margin, 100.0f, self.view.width - margin*2, 200.0f)];
        
        UITextField *usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.width, 50.0f)];
        [view addSubview:usernameTextField];
        
        UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(usernameTextField.frame) + 10.0f, view.width, 50.0f)];
        passwordTextField.secureTextEntry = YES;
        [view addSubview:passwordTextField];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(passwordTextField.frame) + 10.0f, view.width, 50.0f)];
        [button setTitle:@"Login" forState:UIControlStateNormal];
        [[button titleLabel] setFont:[ChannelsInterface mediumFontOfSize:16]];
        [button addTarget:self action:@selector(buttonPressHandler:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        usernameTextField.textColor = passwordTextField.textColor = [UIColor lightGrayColor];
        usernameTextField.backgroundColor = passwordTextField.backgroundColor = [UIColor whiteColor];
        usernameTextField.layer.cornerRadius = passwordTextField.layer.cornerRadius = button.layer.cornerRadius = 3.0f;
        usernameTextField.layer.sublayerTransform = passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        usernameTextField.delegate = passwordTextField.delegate = self;
        
        button.backgroundColor = [UIColor colorWithHexString:@"#2dcc70"];
        
        usernameTextField.text = LoginViewPlaceHolderUsername;
        passwordTextField.text = LoginViewPlaceHolderPassword;
        
        self.loginButton = button;
        self.loginUsernameTextField = usernameTextField;
        self.loginPasswordTextField = passwordTextField;
        
        [view setHeight:CGRectGetMaxY(button.frame)];
        view;
        
    }) : _loginContainerView;
}

- (UIView *)registerContainerView
{
    return !_registerContainerView ? _registerContainerView =
    ({
        CGFloat margin = 20.0f;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(margin, 100.0f, self.view.width - margin*2, 200.0f)];
        
        UITextField *emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.width, 50.0f)];
        [view addSubview:emailTextField];
        
        UITextField *usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(emailTextField.frame) + 10.0f, view.width, 50.0f)];
        [view addSubview:usernameTextField];
        
        UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(usernameTextField.frame) + 10.0f, view.width, 50.0f)];
        passwordTextField.secureTextEntry = YES;
        [view addSubview:passwordTextField];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(passwordTextField.frame) + 10.0f, view.width, 50.0f)];
        [button setTitle:@"Register" forState:UIControlStateNormal];
        [[button titleLabel] setFont:[ChannelsInterface mediumFontOfSize:16]];
        [button addTarget:self action:@selector(buttonPressHandler:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        usernameTextField.textColor = passwordTextField.textColor = emailTextField.textColor = [UIColor lightGrayColor];
        usernameTextField.backgroundColor = passwordTextField.backgroundColor = emailTextField.backgroundColor = [UIColor whiteColor];
        usernameTextField.layer.cornerRadius = passwordTextField.layer.cornerRadius = emailTextField.layer.cornerRadius = button.layer.cornerRadius = 3.0f;
        usernameTextField.layer.sublayerTransform = passwordTextField.layer.sublayerTransform = emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        usernameTextField.delegate = passwordTextField.delegate = emailTextField.delegate = self;
        
        button.backgroundColor = [UIColor colorWithHexString:@"#2dcc70"];
        
        usernameTextField.text = LoginViewPlaceHolderUsername;
        passwordTextField.text = LoginViewPlaceHolderPassword;
        emailTextField.text = LoginViewPlaceHolderEmail;
        
        self.registerButton = button;
        self.registerUsernameTextField = usernameTextField;
        self.registerPasswordTextField = passwordTextField;
        self.registerEmailTextField = emailTextField;
        
        [view setHeight:CGRectGetMaxY(button.frame)];
        view;
    }) : _registerContainerView;
}

- (void)buttonPressHandler:(UIButton *)button
{
    if (button == self.loginButton) {
        [self loginUser];
    }
    
    else if (button == self.registerButton) {
        [self registerUser];
    }
    
    else if (button == self.switchButton) {
        
        [self.view endEditing:YES];
        
        if (self.loginContainerView.isHidden) {
            self.loginContainerView.hidden = NO;
            self.registerContainerView.hidden = YES;
        } else {
            self.loginContainerView.hidden = YES;
            self.registerContainerView.hidden = NO;
        }
    }
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - Remote Calls
#pragma ------------------------------------------------------------------------------------------------------

- (void)loginUser
{
    NSString *username = self.loginUsernameTextField.text;
    NSString *password = self.loginPasswordTextField.text;
    
    if (username.length == 0 || password.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Required Fields" message:@"All fields are required in order to sign in." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
        return;
    }
    
    [UserModel loginWithUsername:username andPassword:password success:^(UserModel *userModel) {
        
        [(ChannelsAppDelegate *)[[UIApplication sharedApplication] delegate] loadListChannelView];
        
    } andFailure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Incorrect username or password." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
    }];
}

- (void)registerUser
{
    NSString *username = self.registerUsernameTextField.text;
    NSString *password = self.registerPasswordTextField.text;
    NSString *email = self.registerEmailTextField.text;
    
    if (username.length == 0 || password.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Required Fields" message:@"All fields are required in order to sign in." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
        return;
    }
    
    [UserModel registerWithUsername:username password:password andEmail:email success:^(UserModel *userModel) {
        
        [(ChannelsAppDelegate *)[[UIApplication sharedApplication] delegate] loadListChannelView];
        
    } andFailure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid entry" message:@"Username and or email is already taken." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
    }];
}

#pragma ------------------------------------------------------------------------------------------------------
#pragma mark - TextField Delegate
#pragma ------------------------------------------------------------------------------------------------------

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    textField.textColor = [UIColor blackColor];
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        
        NSString *titleString = @"";
        
        if (textField == self.loginUsernameTextField || textField == self.registerUsernameTextField) {
            titleString = LoginViewPlaceHolderUsername;
        }
        
        if (textField == self.loginPasswordTextField || textField == self.registerPasswordTextField) {
            titleString = LoginViewPlaceHolderPassword;
        }
        
        if (textField == self.registerEmailTextField) {
            titleString = LoginViewPlaceHolderEmail;
        }
        
        textField.text = titleString;
        textField.textColor = [UIColor lightGrayColor];
    }
    [textField resignFirstResponder];
}


@end
