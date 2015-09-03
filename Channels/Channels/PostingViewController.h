//
//  PostingViewController.h
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, PostingViewFlashState)
{
    PostingViewFlashStateOff = 0,
    PostingViewFlashStateOn
};

typedef NS_ENUM(NSInteger, PostingViewCameraMode)
{
    PostingViewCameraModeBack = 0,
    PostingViewCameraModeFront
};

@interface PostingViewController : BaseViewController

@end