//
//  ChannelPlayerViewModel.h
//  Channels
//
//  Created by Stuart Tett on 9/1/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

@import Foundation;

@interface ChannelPlayerViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *title;

- (void)updateTitle;

@end
