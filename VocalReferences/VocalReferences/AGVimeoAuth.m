//
//  AGVimeoAuth.m
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGVimeoAuth.h"

@implementation AGVimeoAuth

+(AGVimeoAuth*)auth{
    static AGVimeoAuth *auth = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        auth = [[AGVimeoAuth alloc] init];
        auth.consumer = [OAuthConsumer consumerWithKey:kConsumerKey secret:kConsumerSecret authorized:NO];
    });
    return auth;
}


-(void)fetchAccessTokenWithRedirectedURL:(NSURL *)redirectedURL{
    NSString *urlString = [NSString stringWithFormat:@"%@",redirectedURL];
    NSRange range = [urlString rangeOfString:@"vimeodroid://oauth.done?"];
    NSString *response = [urlString substringFromIndex:range.location+range.length];
    
    NSDictionary *parameters = [self parametersFromResponse:response];
    NSLog(@"PARAMETERS: %@",parameters);
    [self fetchAccessTokenWithVerifier:parameters[@"oauth_verifier"]];
}

- (NSDictionary*)parametersFromResponse:(NSString *)response
{
    NSMutableArray* parameters = [NSMutableArray array];
    NSArray* parameterPairs = [response componentsSeparatedByString:@"&"];
    
    for(NSString* parameterString in parameterPairs)
    {
        NSString* key = [[parameterString componentsSeparatedByString:@"="] objectAtIndex:0];
        NSString* value = [[parameterString componentsSeparatedByString:@"="] objectAtIndex:1];
        [parameters addObject:[OAuthParameter parameterWithKey:key andValue:value]];
    }
    NSDictionary* parametersDict = [NSDictionary dictionaryWithOauthParameters:[NSArray arrayWithArray:parameters]];
    return parametersDict;
}

- (NSArray*)parametersFromData:(NSData*)theData
{
    NSMutableArray* parameters = [NSMutableArray array];
    NSArray* parameterPairs = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"&"];
    
    for(NSString* parameterString in parameterPairs)
    {
        NSString* key = [[parameterString componentsSeparatedByString:@"="] objectAtIndex:0];
        NSString* value = [[parameterString componentsSeparatedByString:@"="] objectAtIndex:1];
        [parameters addObject:[OAuthParameter parameterWithKey:key andValue:value]];
    }
    
    return [NSArray arrayWithArray:parameters];
}


- (void)fetchAccessTokenWithVerifier:(NSString*)verifier
{
    NSURL* accessTokenURL = [NSURL URLWithString:kVimeoAccessTokenVerificationURL];
    OAuthRequest* request = [OAuthRequest requestWithURL:accessTokenURL consumer:_consumer token:_token realm:nil signerClass:nil];
    NSHTTPURLResponse* response;
    NSError* error;
    
    [request addParameter:[OAuthParameter parameterWithKey:@"oauth_verifier" andValue:verifier]];
    [request prepare];
    
    NSData* receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *parameters = [NSDictionary dictionaryWithOauthParameters:[self parametersFromData:receivedData]];
    NSLog(@"Access parameters: %@",parameters);
    _vimeoAccessToken = [OAuthToken tokenWithKey:parameters[kVimeoOauthToken] secret:parameters[kVimeoOauthTokenSecret] authorized:YES];
    
    NSLog(@"ACCESS_TOKEN: %@, SECRET: %@",_vimeoAccessToken.key, _vimeoAccessToken.secret);
    [[NSNotificationCenter defaultCenter] postNotificationName:kVimeoDidReciveOauthTokens object:nil];
}

@end
