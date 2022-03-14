//
//  VocalReferences.m
//  VocalReferences
//
//  Created by Andrey Golovin on 28.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "Testimonial.h"


@implementation Testimonial

@dynamic data;
@dynamic image;
@dynamic type;
@dynamic text;
@dynamic companyName;
@dynamic phoneNumber;
@dynamic website;
@dynamic keywords;
@dynamic descript;
@dynamic customer;
@dynamic customerEmail;
@dynamic title;
@dynamic userEmail;
@dynamic date;

+ (NSArray *)getAllTestimonialsForUserEmail:(NSString*)email{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Testimonial" inManagedObjectContext:[Testimonial managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userEmail LIKE[c] %@",email];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedRecords = [[Testimonial managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    fetchedRecords = [[fetchedRecords reverseObjectEnumerator] allObjects];
    
    return fetchedRecords;
}

+ (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(BOOL)remove{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    [context deleteObject:self];
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Error deleting object, %@", [error userInfo]);
        return NO;
    } else {
        NSLog(@"Delete success!!");
        return YES;
    }
}

@end
