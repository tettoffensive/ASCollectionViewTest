//
//  ListViewController.m
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import "ListViewController.h"
@import AsyncDisplayKit;
#import "ItemInfoNode.h"

@interface ListViewController ()<ASCollectionViewDelegate,ASCollectionViewDataSource>
@property (nonatomic) ASCollectionView *myFeedCollectionView;
@property (nonatomic, strong) NSArray<ItemInfo*> *dataSource;
@end

@implementation ListViewController

@dynamic viewModel; // required for covariant return type: https://en.wikipedia.org/wiki/Covariant_return_type

- (instancetype)initWithViewModel:(ListerViewModel *)viewModel
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
    [self.myFeedCollectionView setFrame:frame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
        ASCollectionView *value = [[ASCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout asyncDataFetching:YES];
        [value setAsyncDataSource:self];
        [value setAsyncDelegate:self];
        [value setBackgroundColor:[UIColor clearColor]];
        value;
    }) : _myFeedCollectionView;
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - ASCollectionViewDataSource
#pragma -------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ItemInfo *info = self.dataSource[indexPath.item];
    ItemInfoNode *cell = [[ItemInfoNode alloc] initWithInfo:info];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
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
#pragma mark - ViewModel
#pragma -------------------------------------------------------------------------------------------

- (void)reloadData
{
    [self setTitle:@"Testing ASCollectionView"];
    if (self.viewModel.itemList) {
        self.dataSource = self.viewModel.itemList;
        [self.myFeedCollectionView reloadData];
    }
}

@end
