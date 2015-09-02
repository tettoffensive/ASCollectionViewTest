//
//  POLYViewController.m
//  POLYFoundation
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "POLYViewController.h"

@import KVOController.FBKVOController;
#import "POLYViewModel.h"

@implementation POLYViewController

- (instancetype)initWithViewModel:(POLYViewModel *)viewModel
{
    if (self = [super init]) {
        NSParameterAssert(viewModel);
        [self reloadDataWithModel:viewModel]; // sets the view model
    }
    return self;
}

- (void)dealloc
{
    [self.KVOControllerNonRetaining unobserveAll];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ViewModel Observing
#pragma -------------------------------------------------------------------------------------------

- (void)setupObservers
{
    [self.KVOControllerNonRetaining observe:self.viewModel
                                   keyPaths:self.viewModel.keys
                                    options:NSKeyValueObservingOptionNew
                                      block:^(POLYViewController *observer, POLYViewModel *viewModel, NSDictionary *change) {
                                          [observer reloadDataWithModel:viewModel];
                                      }];
}

- (void)reloadDataWithModel:(POLYViewModel *)viewModel
{
    if (self.viewModel != viewModel) {
        // set or change to new view model
        [self.KVOControllerNonRetaining unobserveAll];
        self.viewModel = viewModel;
        [self setupObservers];
    }
    
    [self reloadData];
}

- (void)reloadData
{
    
}

@end
