//
//  SPDate.m
//  Swipe
//
//  Created by Addison Hardy on 8/19/14.
//  Copyright (c) 2014 Complex Polygon. All rights reserved.
//

#import "POLYDate.h"
#import "POLYFileManager.h"

static double correction;

@implementation POLYDate

+ (void)setCorrectTime:(double)timestamp
{
    NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970: timestamp];
    double difference = [serverDate timeIntervalSinceNow] / 60.0;
    if (fabs(difference) > 10) {
        correction = difference;
    } else {
        correction = 0;
    }
}

+ (NSDate *)correctDate
{
    if (fabs(correction) > 0.0) {
        return [NSDate dateWithTimeIntervalSinceNow: correction];
    } else {
        return [NSDate new];
    }
}

@end
