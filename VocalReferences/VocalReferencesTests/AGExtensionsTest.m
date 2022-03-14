//
//  AGExtensionsTest.m
//  VocalReferences
//
//  Created by Andrey Golovin on 18.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface AGExtensionsTest : XCTestCase

@end

@implementation AGExtensionsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBackButtonAndButtonFonts {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button thisIsBackButtonWithOptionalFont:nil andColor:nil];
    XCTAssertEqualObjects([button attributedTitleForState:UIControlStateNormal].string, @" Back", @"Not work");
    [button applyAwesomeFontWithSize:20];
    UIFont *testFont = [UIFont fontWithName:kAwesomeFont size:20.];
    XCTAssertEqualObjects(button.titleLabel.font, testFont, @"Not work!");
}

-(void)testDictionaryToJson{
    NSDictionary *dict = @{@"key":@"value"};
    XCTAssertEqualObjects(dict.JSON, @"{\n  \"key\" : \"value\"\n}",@"Not work!");
}

-(void)testUserData{
    NSString *email = @"email$&#@gmail.com";
    NSString *username = @"*&^#name";
    XCTAssertFalse([email isCorrectEmail], @"Not work!");
    XCTAssertFalse([username isCorrectUsername], @"Not work!");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
