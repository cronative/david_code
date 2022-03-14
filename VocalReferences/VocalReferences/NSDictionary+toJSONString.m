//
//  NSDictionary+toJSONString.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "NSDictionary+toJSONString.h"

@implementation NSDictionary (toJSONString)

-(NSString*)JSON{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

@end
