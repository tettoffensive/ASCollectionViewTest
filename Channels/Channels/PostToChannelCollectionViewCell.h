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

- (void)setupCellWithChannel:(ChannelModel *)channel;

@end
