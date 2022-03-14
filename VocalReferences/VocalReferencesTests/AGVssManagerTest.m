//
//  AGVssManagerTest.m
//  VocalReferences
//
//  Created by Andrey Golovin on 13.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AGVssManager.h"

@interface AGVssManagerTest : XCTestCase

@end

@implementation AGVssManagerTest

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetAllVSS {
    NSString * auth = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthToken];
    XCTAssertNotNil(auth,@"Need Login in the app!");
    if(auth){
        XCTestExpectation *apiExpect = [self expectationForNotification:kVssDidLoadNotification object:nil handler:^BOOL(NSNotification *notification) {
            XCTAssertNotNil([[AGVssManager manager] getAllVss], @"Error!");
            [apiExpect fulfill];
            return YES;
        }];
        [[AGVssManager manager] loadAllVss];

        [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
            XCTAssertNil(error,@"Error!");
        }];
    }
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
