//
//  PostToChannelCollectionViewCell.h
//  Channels
//
//  Created by Dana Shakiba on 9/10/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelModel.h"

@interface PostToChannelCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;

- (void)setupCellWithChannel:(ChannelModel *)channel;

@end