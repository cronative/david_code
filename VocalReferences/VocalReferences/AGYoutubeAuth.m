//
//  AGYoutubeAuth.m
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGYoutubeAuth.h"

static NSString *const kYoutubeAccessToken = @"access_token";
static NSString *const kYoutubeExpiresIn = @"expires_in";
static NSString *const kYoutubeRefreshToken = @"refresh_token";
static NSString *const kYoutubeTokenType = @"token_type";

@implementation AGYoutubeAuth

+(AGYoutubeAuth*)auth{
    static AGYoutubeAuth *auth = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        auth = [[AGYoutubeAuth alloc] init];
    });
    return auth;
}

-(void)getTokensWithRedirectURL:(NSURL *)redirectURL{
    NSString *urlString = [NSString stringWithFormat:@"%@",redirectURL];
    NSRange range = [urlString rangeOfString:@"com.vocalreferences.1:/oauth2callback2?code="];
    NSString *code = [urlString substringFromIndex:range.length+range.location];
    NSLog(@"Access code: %@",code);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:@"https://accounts.google.com/o/oauth2/token" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
        [formData appendPartWithFormData:[code dataUsingEncoding:NSUTF8StringEncoding] name:@"code"];
        [formData appendPartWithFormData:[kGoogleClientId dataUsingEncoding:NSUTF8StringEncoding] name:@"client_id"];
        [formData appendPartWithFormData:[kGoogleSecret dataUsingEncoding:NSUTF8StringEncoding] name:@"client_secret"];
        [formData appendPartWithFormData:[@"com.vocalreferences.1:/oauth2callback2" dataUsingEncoding:NSUTF8StringEncoding] name:@"redirect_uri"];
        [formData appendPartWithFormData:[@"authorization_code" dataUsingEncoding:NSUTF8StringEncoding] name:@"grant_type"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        _accessToken = [NSString stringWithFormat:@"%@",responseObject[kYoutubeAccessToken]];
        _expiresIn = [NSString stringWithFormat:@"%@",responseObject[kYoutubeExpiresIn]];
        _refreshToken = [NSString stringWithFormat:@"%@",responseObject[kYoutubeRefreshToken]];
        _tokenType = [NSString stringWithFormat:@"%@",responseObject[kYoutubeTokenType]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kYoutubeDidReciveOauthTokens object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"operation: %@",operation.responseString);
    }];
}

@end
