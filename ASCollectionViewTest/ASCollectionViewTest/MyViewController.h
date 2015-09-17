//
//  MyViewController.h
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

@import UIKit;

@class ViewModel;

@interface MyViewController<ViewModelType:ViewModel *> : UIViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithViewModel:(ViewModelType)viewModel;
- (void)reloadData;

@property (nonatomic, strong) ViewModelType viewModel;

@end
