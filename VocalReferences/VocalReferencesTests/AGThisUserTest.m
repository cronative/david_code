//
//  AGThisUserTest.m
//  VocalReferences
//
//  Created by Andrey Golovin on 17.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface AGThisUserTest : XCTestCase

@end

@implementation AGThisUserTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUserUpdate{
    NSString * auth = [[AGThisUser currentUser] getUserAuthToken];
    XCTAssertNotNil(auth,@"Need Login in the app!");
    if(auth){
        XCTestExpectation *userExpect = [self expectationForNotification:@"userUpdated" object:nil handler:^BOOL(NSNotification *notification) {
            XCTAssertNotNil([AGThisUser currentUser].companyName, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].country, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].state, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].postalCode, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].phoneNumber, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].firstName, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].lastName, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].address, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].city, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].website, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].businessCategory, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].tinyurl, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].accountType, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].googleCloudFileName, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].googlId, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].isRated, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].isYoutubeDefault, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].limitRecords, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].phonId, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].purchaseDate, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].rateNotificDate, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].videoAvatar, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].youtubePassword, @"Error!");
            XCTAssertNotNil([AGThisUser currentUser].youtubeUsername, @"Error!");
            [userExpect fulfill];
            return YES;
        }];
        [[AGThisUser currentUser] updateProfile];
        
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
