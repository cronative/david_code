//
//  AGVimeoAuth.h
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuth.h"
#import "VimeoConstants.h"

#define kConsumerKey @"95b6479deb20019a3ac726776374ad5332a526e7"
#define kConsumerSecret @"1170f0c5654f61cdf4c58dc800d2f7a499d1fe6c"

@interface AGVimeoAuth : NSObject

+(AGVimeoAuth*)auth;

-(void)fetchAccessTokenWithRedirectedURL:(NSURL *)redirectedURL;
- (NSArray*)parametersFromData:(NSData*)theData;

@property (nonatomic, strong) OAuthToken* token;
@property (nonatomic, strong) OAuthConsumer* consumer;
@property (nonatomic, strong) OAuthToken *vimeoAccessToken;



@end
