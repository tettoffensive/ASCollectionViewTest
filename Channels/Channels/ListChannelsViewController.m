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

@interface ListChannelsViewController ()<ASCollectionViewDelegate,ASCollectionViewDataSource,ChannelInfoNodeDelegate>
@property (nonatomic) ASCollectionView *myFeedCollectionView;
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
}

- (void)viewWillLayoutSubviews
{
    CGRect frame = self.view.bounds;
    frame.origin.x   += 10;
    frame.size.width -= 10;
    [self.myFeedCollectionView setFrame:frame];
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

@end
