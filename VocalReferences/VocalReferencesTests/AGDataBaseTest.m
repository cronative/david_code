//
//  AGDataBaseTest.m
//  VocalReferences
//
//  Created by Andrey Golovin on 17.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Testimonial.h"

@interface AGDataBaseTest : XCTestCase{
    Testimonial *testimonialObject;
}

@end

@implementation AGDataBaseTest

- (void)setUp {
    [super setUp];
    testimonialObject = [NSEntityDescription insertNewObjectForEntityForName:@"Testimonial"inManagedObjectContext:self.managedObjectContext];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddTestimonial{
    testimonialObject.userEmail = @"testmail@gmail.com";
    testimonialObject.date = [NSDate date];
    testimonialObject.type = [NSNumber numberWithInt:1];
    testimonialObject.text = @"Text";
    testimonialObject.title = @"Title";
    testimonialObject.companyName = @"Company";
    testimonialObject.phoneNumber = @"1234567890";
    testimonialObject.website = @"www.site.com";
    testimonialObject.keywords = @"key";
    testimonialObject.descript = @"description";
    testimonialObject.customer = @"customer";
    testimonialObject.customerEmail = @"customerEmail";
    testimonialObject.image = UIImageJPEGRepresentation([UIImage imageNamed:@"recordText"], 1.f);
    NSError *error;
    XCTAssert([self.managedObjectContext save:&error],@"Not saved");
    XCTAssertNil(error, @"Error!");
}

-(void)testLoadAllTestimonialsFromDB{
    NSArray *testimonials = [Testimonial getAllTestimonialsForUserEmail:@"testmail@gmail.com"];
    XCTAssert(testimonials.count, @"Empty DB!");
    if(testimonials.count > 0){
        Testimonial *testimonial = testimonials[0];
        XCTAssertNotNil(testimonial, @"Empty DB!");
        XCTAssertEqualObjects(testimonial.userEmail, @"testmail@gmail.com");
        XCTAssertNotNil(testimonial.date, @"No date!");
        XCTAssertEqualObjects(testimonial.type, [NSNumber numberWithInt:1]);
        XCTAssertEqualObjects(testimonial.text, @"Text");
        XCTAssertEqualObjects(testimonial.title, @"Title");
        XCTAssertEqualObjects(testimonial.companyName, @"Company");
        XCTAssertEqualObjects(testimonial.phoneNumber, @"1234567890");
        XCTAssertEqualObjects(testimonial.website, @"www.site.com");
        XCTAssertEqualObjects(testimonial.keywords, @"key");
        XCTAssertEqualObjects(testimonial.descript, @"description");
        XCTAssertEqualObjects(testimonial.customer, @"customer");
        XCTAssertEqualObjects(testimonial.customerEmail, @"customerEmail");
        XCTAssertNotNil(testimonial.image, @"No image!");
    }
}

-(void)testRemoveAllTestimonialFromDb{
    NSArray *testimonials = [Testimonial getAllTestimonialsForUserEmail:@"testmail@gmail.com"];
    XCTAssert(testimonials.count, @"Empty DB!");
    for(Testimonial *testimonial in testimonials){
        XCTAssert([testimonial remove], @"Not remove!!");
    }
}

-(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
