//
//  ListChannelsViewController.m
//  Channels
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ListChannelsViewController.h"
@import AsyncDisplayKit;
#import "ChannelInfoNode.h"
#import "ChannelPlayerViewModel.h"
#import "ChannelViewController.h"
#import "PostingViewController.h"
#import "PostingViewModel.h"

@interface ListChannelsViewController ()<ASCollectionViewDelegate,ASCollectionViewDataSource,ChannelInfoNodeDelegate>
@property (nonatomic) ASCollectionView *myFeedCollectionView;
@property (nonatomic, strong) UIButton *postButton;
@end

@implementation ListChannelsViewController

@dynamic viewModel; // required for covariant return type: https://en.wikipedia.org/wiki/Covariant_return_type

- (instancetype)initWithViewModel:(ChannelListerViewModel *)viewModel
{
    if (self = [super initWithViewModel:viewModel]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.myFeedCollectionView];
    [self.view addSubview:self.postButton];
}

- (void)viewWillLayoutSubviews
{
    CGRect frame = self.view.bounds;
    frame.origin.x   += 10;
    frame.size.width -= 10;
    [self.myFeedCollectionView setFrame:frame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:_postButton];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Properties
#pragma -------------------------------------------------------------------------------------------

- (ASCollectionView *)myFeedCollectionView
{
    return !_myFeedCollectionView ? _myFeedCollectionView =
    ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        ASCollectionView *value = [[ASCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout asyncDataFetching:YES];
        [value setAsyncDataSource:self];
        [value setAsyncDelegate:self];
        [value setBackgroundColor:[UIColor clearColor]];
        value;
    }) : _myFeedCollectionView;
}

- (UIButton *)postButton
{
    return !_postButton ? _postButton =
    ({
        UIImage *postButtonImage = [UIImage imageNamed:@"Camera Button"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, postButtonImage.size.width, postButtonImage.size.height)];
        [button setCenter:self.view.center];
        [button setFrame:CGRectOffset(button.frame, 0.0f, self.view.bounds.size.height/2.0 - 60.0f)];
        [button setImage:postButtonImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showPostViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    }) : _postButton;
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ASCollectionViewDataSource
#pragma -------------------------------------------------------------------------------------------

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelInfo *info = self.viewModel.channelList[indexPath.item];
    ChannelInfoNode *cell = [[ChannelInfoNode alloc] initWithInfo:info];
    [cell setDelegate:self];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.channelList.count;
}

- (void)collectionViewLockDataSource:(ASCollectionView *)collectionView
{
    // lock the data source
    // The data source should not be change until it is unlocked.
}

- (void)collectionViewUnlockDataSource:(ASCollectionView *)collectionView
{
    // unlock the data source to enable data source updating.
}

- (void)collectionView:(UICollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context
{
    NSLog(@"fetch additional content");
    [context completeBatchFetching:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ChannelInfoNode Delegate
#pragma -------------------------------------------------------------------------------------------

- (void)channelNodeWasTapped:(ChannelInfo *)channel
{
    POLYLog(@"Channel Was Tapped:", channel);
    
    ChannelPlayerViewModel *viewModel = [ChannelPlayerViewModel new];
    [viewModel updatePostsForChannel:channel];
    ChannelViewController *channelViewController = [[ChannelViewController alloc] initWithViewModel:viewModel];
    [self.navigationController presentViewController:channelViewController animated:YES completion:NULL];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ViewModel
#pragma -------------------------------------------------------------------------------------------

- (void)reloadData
{
    [self setTitle:self.viewModel.listTitle];
    [self.myFeedCollectionView reloadData];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Posting View Controller
#pragma -------------------------------------------------------------------------------------------

- (void)showPostViewController
{
    PostingViewModel *postingViewModel = [[PostingViewModel alloc] init];
    PostingViewController *postViewController = [[PostingViewController alloc] initWithViewModel:postingViewModel];
    [self.navigationController presentViewController:postViewController animated:NO completion:NULL];
}

@end
