//
//  VocalReferences.h
//  VocalReferences
//
//  Created by Andrey Golovin on 28.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Testimonial : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSString * descript;
@property (nonatomic, retain) NSString * customer;
@property (nonatomic, retain) NSString * customerEmail;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * userEmail;
@property (nonatomic, retain) NSDate * date;

+ (NSArray *)getAllTestimonialsForUserEmail:(NSString*)email;
-(BOOL)remove;

@end
