//
//  Application.m
//  VocalReferences
//
//  Created by Andrey Golovin on 13.04.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "Application.h"

@implementation Application

-(BOOL)openURL:(NSURL *)url{
    if ([[url absoluteString] hasPrefix:@"https://accounts.google.com/o/oauth2/auth"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationOpenGoogleAuthNotification object:url];
        return NO;
        
    } else if([[url absoluteString] hasPrefix:YOUTUBE]){
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationOpenGoogleAuthNotification object:url];
        return NO;
    } else {
        return [super openURL:url];
    }
}

@end
