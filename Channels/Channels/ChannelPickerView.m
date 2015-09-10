//
//  ChannelPickerView.m
//  Channels
//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import "ChannelPickerView.h"
#import "PostToChannelCollectionViewCell.h"
#import "ChannelsCollectionViewFlowLayout.h"
#import "ChannelModel.h"
#import "ChannelsInterface.h"
#import "PostToChannelToolbar.h"

@interface ChannelPickerView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *createChannelButton;
@property (nonatomic, strong) UICollectionView *channelsCollectionView;
@property (nonatomic, strong) NSArray *channelsData;
@property (nonatomic, strong) PostToChannelToolbar *postToChannelToolbar;

@end

@implementation ChannelPickerView

static NSString *kChannelsCollectionViewCellIdentifier = @"PostToChannelCollectionViewCell";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _backgroundView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.4f] CGColor], nil];
        [_backgroundView.layer insertSublayer:gradient atIndex:0];
        [self addSubview:_backgroundView];
        
        _createChannelButton = [[UIButton alloc] initWithImageName:@"Create Channel Button"];
        [_createChannelButton setFrame:CGRectMake(self.bounds.size.width - _createChannelButton.imageView.bounds.size.width,
                                                  self.bounds.origin.y,
                                                  _createChannelButton.imageView.bounds.size.width,
                                                  _createChannelButton.imageView.bounds.size.height)];
        [_createChannelButton addTarget:self action:@selector(createChannel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_createChannelButton];
        
        ChannelsCollectionViewFlowLayout *cVLayout = [[ChannelsCollectionViewFlowLayout alloc] init];
        _channelsCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                     collectionViewLayout:cVLayout];
        _channelsCollectionView.frame = CGRectInset(_channelsCollectionView.frame, 8.0f, 0.0f);
        _channelsCollectionView.delegate = self;
        _channelsCollectionView.dataSource = self;
        [_channelsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kChannelsCollectionViewCellIdentifier];
        UINib *cellNib = [UINib nibWithNibName:@"PostToChannelCollectionViewCell" bundle:nil];
        [_channelsCollectionView registerNib:cellNib forCellWithReuseIdentifier:kChannelsCollectionViewCellIdentifier];
        [_channelsCollectionView setBackgroundColor:[UIColor clearColor]];
        [_channelsCollectionView setShowsHorizontalScrollIndicator:NO];
        [_channelsCollectionView setShowsVerticalScrollIndicator:NO];
        [_channelsCollectionView setAllowsMultipleSelection:NO];
        [self addSubview:_channelsCollectionView];
        _channelsData = [NSArray new];
        [self loadChannels];
        
        CGFloat toolbarHeight = 44.0f;
        _postToChannelToolbar = [[PostToChannelToolbar alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                                       self.bounds.size.height - toolbarHeight,
                                                                                       self.bounds.size.width,
                                                                                       toolbarHeight)];
        [self addSubview:_postToChannelToolbar];
    }
    return self;
}

- (void)loadChannels
{
    [ChannelModel fetchChannelsWithSuccess:^(NSArray<ChannelModel *> *channels) {
        NSLog(@"Channels: %@", channels);
        [self setChannelsData:channels];
    } andFailure:^(NSError *error) {
        if (error) {
            NSLog(@"Error Fetching Channels: %@", [error description]);
        }
    }];
}

- (void)setChannelsData:(NSArray *)channelsData
{
    _channelsData = [channelsData copy];
    [_channelsCollectionView reloadData];
}

#pragma -------------------------------------------------------------------------------------------
#pragma mark - Channels Collection View Delegate Methods
#pragma -------------------------------------------------------------------------------------------

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    PostToChannelCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kChannelsCollectionViewCellIdentifier forIndexPath:indexPath];
    
    ChannelModel *channel = [_channelsData objectAtIndex:indexPath.item];
    [cell setChannelTitleAttributedTextWithString:channel.title];
    cell.channelImageView.image = [UIImage imageNamed:@"Cell Placeholder"];
    
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [_channelsData count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didSelectItemAtIndexPath %li", indexPath.item);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [cell setSelected:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didDeselectItemAtIndexPath %li", indexPath.item);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [cell setSelected:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(94, 105);
}



- (void)createChannel
{
    NSLog(@"Create Channel Button Pressed");
}

@end
