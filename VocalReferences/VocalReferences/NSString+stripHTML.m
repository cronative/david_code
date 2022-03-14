//
//  NSString+stripHTML.m
//  VocalReferences
//
//  Created by Andrey Golovin on 19.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "NSString+stripHTML.h"

@implementation NSString (stripHTML)

-(NSString *) stringByStrippingHTML{
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    
    s = [s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    return s;
}

-(NSString *) stringWithoutNull{
    if([self isEqualToString:@"<null>"] || [self isEqualToString:@"(null)"]){
        return @"";
    } else {
        return self;
    }
}

@end
