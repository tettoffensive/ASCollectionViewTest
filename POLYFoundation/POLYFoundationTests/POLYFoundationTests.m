//
//  POLYFoundationTests.m
//  POLYFoundationTests
//
//  Created by Stuart Tett on 8/28/15.
//  Copyright (c) 2015 Complex Polygon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "POLYUtils.h"
#import "POLYFileManager.h"

#define CONFIG_AMAZON_S3_ACCESS_KEY @"AKIAIK7DKZPP7GCBYHZA"
#define CONFIG_AMAZON_S3_SECRET_KEY @"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"

@interface POLYFoundationTests : XCTestCase

@property (nonatomic) POLYFileManager *fileManager;

@end

@implementation POLYFoundationTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.fileManager = [[POLYFileManager alloc] initWithAccessKey:CONFIG_AMAZON_S3_ACCESS_KEY
                                                    withSecretKey:CONFIG_AMAZON_S3_SECRET_KEY];
    [self.fileManager setBucket:@"swipe-admin"];
    [self.fileManager setSubpath:@"test"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUploadImage
{
    UIImage *image = [POLYUtils imageWithColor:[UIColor magentaColor] andSize:CGSizeMake(100, 100)];
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"testUploadImage"];
    __block XCTestExpectation *expectation2 = [self expectationWithDescription:@"testDownloadImage"];
    
    [self.fileManager uploadImage:image progress:nil success:^(BOOL finished, NSString *key) {
        XCTAssert(finished,@"Upload Finished");
        XCTAssert([key length] > 0, @"Upload Has Key");
        [expectation fulfill];
        expectation = nil;
        
        // NOW DOWNLOAD THE SAME FILE
        [self.fileManager downloadImageWithKey:key progress:nil success:^(UIImage *image) {
            NSData *resampled = UIImageJPEGRepresentation(image, 0.85);
            XCTAssert([resampled length] > 0, @"Download ");
            [expectation2 fulfill];
            expectation2 = nil;
        } failure:^(NSError *err) {
            XCTFail(@"Download Failed");
            [expectation2 fulfill];
            expectation2 = nil;
        }];
        
    } failure:^(NSError *err) {
        XCTFail(@"Upload Failed");
        [expectation fulfill];
        expectation = nil;
    }];
    
    [self waitForExpectationsWithTimeout:120 handler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

@end
