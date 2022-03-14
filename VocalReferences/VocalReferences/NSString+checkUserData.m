//
//  NSString+checkUserData.m
//  CrazyChow
//
//  Created by Andrey Golovin on 26.09.13.
//  Copyright (c) 2013 Jelvix. All rights reserved.
//

#import "NSString+checkUserData.h"

@implementation NSString (checkUserData)

-(BOOL)isCorrectEmail{
    if([[self componentsSeparatedByString:@"@"] count] == 2){
        if ([[[[self componentsSeparatedByString:@"@"] objectAtIndex:1] componentsSeparatedByString:@"."] count] >=2) {
            NSCharacterSet *incorrectCharacters = [NSCharacterSet characterSetWithCharactersInString:@"`~!#$%^&*()=+{}|\"\';:\\/?>< "];
            NSRange rangeOfIncCharacters = [self rangeOfCharacterFromSet:incorrectCharacters];
            if(rangeOfIncCharacters.length > 0){
                return NO;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

-(BOOL)isCorrectUsername{
    NSCharacterSet *incorrectCharacters = [NSCharacterSet characterSetWithCharactersInString:@"`~!@#$%^&*()-=+_{}|\"\';:\\/?><., "];
    NSRange rangeOfIncCharacters = [self rangeOfCharacterFromSet:incorrectCharacters];
    if(rangeOfIncCharacters.length > 0){
        return NO;
    } else {
        return YES;
    }
}

@end
