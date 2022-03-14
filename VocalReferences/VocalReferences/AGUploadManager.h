//
//  AGUploadManager.h
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Testimonial.h"

extern NSString *const kObjectUploadedNotification;
extern NSString *const kManagerDidFinishUploadingNotification;

@interface AGUploadManager : NSObject

+(AGUploadManager*)uploader;

-(BOOL)uploading;
-(void)uploadTestimonials:(NSArray *)testimonials;
-(BOOL)isUploadingNowTestimonial:(Testimonial*)testimonial;
-(void)addTestimonialToUpload:(NSArray *)testimonials;
@end
