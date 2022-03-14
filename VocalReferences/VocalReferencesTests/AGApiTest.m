//
//  AGApiTest.m
//  VocalReferences
//
//  Created by Andrey Golovin on 26.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AGApi.h"

@interface AGApiTest : XCTestCase

@end

@implementation AGApiTest{
    AGApi *api;
}

- (void)setUp {
    [super setUp];
    api = [AGApi new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetIntro {
    XCTestExpectation *apiExpect = [self expectationWithDescription:@"get intro"];
    
    [api POSTrequestWithMethod:GET_INTRO parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
        BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
        XCTAssert(result,@"Success!");
        [apiExpect fulfill];
    } failure:^(NSError *error, NSString *errorString) {
        XCTAssertNil(error,@"Error get intro");
        [apiExpect fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error,@"Error!");
    }];
}

- (void)testGetLinkForUpload {
    XCTestExpectation *apiExpect = [self expectationWithDescription:@"get upload link"];
    
    [api POSTrequestWith:GET_CLOUD_LINK parameters:nil success:^(id response, id wrongObject) {
        NSString *path = response[@"link"];
        XCTAssertNotNil(path,@"Success!");
        [apiExpect fulfill];
    } failure:^(NSError *error, NSString *errorString) {
        XCTAssertNil(error,@"Error get intro");
        [apiExpect fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error,@"Error!");
    }];
}

-(void)testGetProfile{
    NSString * auth = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthToken];
    XCTAssertNotNil(auth,@"Need Login in the app!");
    if(auth){
        XCTestExpectation *apiExpect = [self expectationWithDescription:@"get profile"];
        NSString *methode = [NSString stringWithFormat:@"%@%@",GET_PROFILE,auth];
        [api GETrequestWithMethode:methode parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
            BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
            XCTAssert(result,@"Bad result");
            XCTAssertNotNil(response[kJsonObjectKey],@"No object");
            [apiExpect fulfill];
        } failure:^(NSError *error, NSString *errorString) {
            XCTAssertNil(error,@"Error!");
            [apiExpect fulfill];
        }];
        [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
            XCTAssertNil(error,@"Error!");
        }];
        
    }
}

-(void)testGetAllVss{
    NSString * auth = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthToken];
    XCTAssertNotNil(auth,@"Need Login in the app!");
    if(auth){
        XCTestExpectation *apiExpect = [self expectationWithDescription:@"get all vss"];
        NSString *methode = [NSString stringWithFormat:@"%@%@",GET_ALL_VSS,auth];
        [api GETrequestWithMethode:methode parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
            BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
            XCTAssert(result,@"Bad result");
            XCTAssertNotNil(response[kRecords],@"No object");
            [apiExpect fulfill];
        } failure:^(NSError *error, NSString *errorString) {
            XCTAssertNil(error,@"Error!");
            [apiExpect fulfill];
        }];
        [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
            XCTAssertNil(error,@"Error!");
        }];
    }
}

-(void)testGetUserVss{
    NSString * auth = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthToken];
    XCTAssertNotNil(auth,@"Need Login in the app!");
    if(auth){
        XCTestExpectation *apiExpect = [self expectationWithDescription:@"get user vss"];
        NSString *methode = [NSString stringWithFormat:@"%@%@",GET_USER_VSS,auth];
        [api GETrequestWithMethode:methode parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
            BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
            XCTAssert(result,@"Bad result");
            XCTAssertNotNil(response[kRecords],@"No object");
            [apiExpect fulfill];
        } failure:^(NSError *error, NSString *errorString) {
            XCTAssertNil(error,@"Error!");
            [apiExpect fulfill];
        }];
        [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
            XCTAssertNil(error,@"Error!");
        }];
    }
}

-(void)testGetAllRecords{
    NSString * auth = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthToken];
    XCTAssertNotNil(auth,@"Need Login in the app!");
    if(auth){
        XCTestExpectation *apiExpect = [self expectationWithDescription:@"get all records"];
        NSString *methode = [NSString stringWithFormat:@"%@%@",GET_ALLRECORDS,auth];
        [api GETrequestWithMethode:methode parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
            BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
            XCTAssert(result,@"Bad result");
            XCTAssertNotNil(response[kRecords],@"No object");
            [apiExpect fulfill];
        } failure:^(NSError *error, NSString *errorString) {
            XCTAssertNil(error,@"Error!");
            [apiExpect fulfill];
        }];
        [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
            XCTAssertNil(error,@"Error!");
        }];
    }
}
@end
