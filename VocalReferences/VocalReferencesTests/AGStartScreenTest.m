//
//  VocalReferencesTests.m
//  VocalReferencesTests
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AGStartScreenViewController.h"

@interface AGStartScreenTest : XCTestCase

@end

@implementation AGStartScreenTest{
    AGStartScreenViewController *vc;
}

- (void)setUp {
    [super setUp];
    vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"startScreenViewController"];
    [vc view];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testLoadingVC{
    XCTAssertNotNil(vc,@"Viewcontroller load success");
}

-(void)testViewControllerViewExists{
    XCTAssertNotNil(vc.view, @"View is exist");
}

-(void)testWebViewConnection{
    XCTAssertNotNil(vc.webView, @"webview connected");
}


@end
