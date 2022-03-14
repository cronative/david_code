//
//  AGDefaultUserInfoTest.m
//  VocalReferences
//
//  Created by Andrey Golovin on 17.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AGDefaultInfo.h"

@interface AGDefaultUserInfoTest : XCTestCase{
    AGDefaultInfo *info;
}

@end

@implementation AGDefaultUserInfoTest

- (void)setUp {
    [super setUp];
    info = [[AGDefaultInfo alloc] init];
    [info remove];
    info = [[AGDefaultInfo alloc] init];
    XCTAssertNil(info.companyName, @"Not removed!");
    XCTAssertNil(info.phoneNumber, @"Not removed!");
    XCTAssertNil(info.website, @"Not removed!");
    XCTAssertNil(info.keywords, @"Not removed!");
    XCTAssertNil(info.descript, @"Not removed!");
    info.companyName = @"company";
    info.phoneNumber = @"1234567890";
    info.website = @"www.test.com";
    info.keywords = @"key";
    info.descript = @"description";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSave{
    [info save];
    AGDefaultInfo *savedDefaults = [[AGDefaultInfo alloc] init];
    XCTAssertEqualObjects(savedDefaults.companyName, @"company");
    XCTAssertEqualObjects(savedDefaults.phoneNumber, @"1234567890");
    XCTAssertEqualObjects(savedDefaults.website, @"www.test.com");
    XCTAssertEqualObjects(savedDefaults.keywords, @"key");
    XCTAssertEqualObjects(savedDefaults.descript, @"description");
}

-(void)testRemove{
    [info remove];
    AGDefaultInfo *savedDefaults = [[AGDefaultInfo alloc] init];
    XCTAssertNil(savedDefaults.companyName, @"Not removed!");
    XCTAssertNil(savedDefaults.phoneNumber, @"Not removed!");
    XCTAssertNil(savedDefaults.website, @"Not removed!");
    XCTAssertNil(savedDefaults.keywords, @"Not removed!");
    XCTAssertNil(savedDefaults.descript, @"Not removed!");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
