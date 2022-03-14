//
//  AGYoutubeAuth.h
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGYoutubeAuth : NSObject

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *expiresIn;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *tokenType;

+(AGYoutubeAuth*)auth;

-(void)getTokensWithRedirectURL:(NSURL *)redirectURL;

@end
