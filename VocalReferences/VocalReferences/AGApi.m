//
//  AGApi.m
//  ViralVet
//
//  Created by Andrey Golovin on 27.10.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGApi.h"
static NSInteger const kNoInternetConnectionCode = -1009;

@implementation AGApi

-(void)uploadPhotoWithMethod:(NSString *)method parameters:(NSDictionary *)parameters withAuthorization:(BOOL)withAuth data:(NSData *)data photoKey:(NSString*)photoKey success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *url = [NSString stringWithFormat:@"%@",method];
    _successBlock = success;
    _failureBlock = failure;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:photoKey fileName:@"video.mp4" mimeType:@"video/mp4"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Operation: %@",operation.response);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(_successBlock){
            _successBlock(responseObject,operation.responseData);
        }
        _successBlock = nil;
        _failureBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR!!%@",operation.responseObject);
        NSLog(@"ERROR: %@",operation.response);
        if(error.code == kNoInternetConnectionCode){
           
        }
        if(_failureBlock){
            _failureBlock(error, [self getErrorStringFrom:operation]);
        }
        _successBlock = nil;
        _failureBlock = nil;
    }];
}

-(void)POSTrequestWith:(NSString*)url parameters:(NSDictionary*)parameters success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _successBlock = success;
    _failureBlock = failure;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(_successBlock){
            _successBlock(responseObject,nil);
        }
        _successBlock = nil;
        _failureBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR!!%@",operation.responseObject);
        NSLog(@"ERROR: %@",operation.response);
        if(error.code == kNoInternetConnectionCode){
            NSLog(@"No internet connection!");
        }
        if(_failureBlock){
            _failureBlock(error, [self getErrorStringFrom:operation]);
        }
        _successBlock = nil;
        _failureBlock = nil;
    }];
}
-(void)POSTrequestWithMethod:(NSString*)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",APP_DOMAIN,method];
    _successBlock = success;
    _failureBlock = failure;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    if(withAuth){
        [manager.requestSerializer setValue:[[AGThisUser currentUser] getUserAuthToken] forHTTPHeaderField:kAuthToken];
    }
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(_successBlock){
            _successBlock(responseObject,nil);
        }
        _successBlock = nil;
        _failureBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR!!%@",operation.responseObject);
        NSLog(@"ERROR: %@",operation.response);
        if(error.code == kNoInternetConnectionCode){
            NSLog(@"No internet connection!");
        }
        if(_failureBlock){
            _failureBlock(error, [self getErrorStringFrom:operation]);
        }
        _successBlock = nil;
        _failureBlock = nil;
    }];
}

-(void)DELETErequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@",APP_DOMAIN,method];
    _successBlock = success;
    _failureBlock = failure;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    if(withAuth){
        [manager.requestSerializer setValue:[[AGThisUser currentUser] getUserAuthToken] forHTTPHeaderField:kAuthToken];
    }
    
    [manager DELETE:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(_successBlock){
            _successBlock(responseObject,nil);
        }
        _successBlock = nil;
        _failureBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR!!%@",operation.responseObject);
        NSLog(@"ERROR: %@",operation.response);
        if(error.code == kNoInternetConnectionCode){
            NSLog(@"No internet connection!");
        }
        if(_failureBlock){
            _failureBlock(error,[self getErrorStringFrom:operation]);
        }
        _successBlock = nil;
        _failureBlock = nil;
    }];
}

-(void)GETrequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@",APP_DOMAIN,method];
    _successBlock = success;
    _failureBlock = failure;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if(withAuth){
        [manager.requestSerializer setValue:[[AGThisUser currentUser] getUserAuthToken] forHTTPHeaderField:kAuthToken];
    }
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(_successBlock){
            _successBlock(responseObject,nil);
        }
        _successBlock = nil;
        _failureBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR!!%@",operation.responseObject);
        NSLog(@"ERROR: %@",operation.response);
        if(error.code == kNoInternetConnectionCode){
            NSLog(@"No internet connection!");
        }
        if(_failureBlock){
            _failureBlock(error,[self getErrorStringFrom:operation]);
        }
        _successBlock = nil;
        _failureBlock = nil;
    }];
}

-(void)PUTrequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@",APP_DOMAIN,method];
    _successBlock = success;
    _failureBlock = failure;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    if(withAuth){
        [manager.requestSerializer setValue:[[AGThisUser currentUser] getUserAuthToken] forHTTPHeaderField:kAuthToken];
    }
    
    [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(_successBlock){
            _successBlock(responseObject,nil);
        }
        _successBlock = nil;
        _failureBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR!!%@",operation.responseObject);
        NSLog(@"ERROR: %@",operation.response);
        if(error.code == kNoInternetConnectionCode){
            NSLog(@"No internet connection!");
        }
        if(_failureBlock){
            _failureBlock(error, [self getErrorStringFrom:operation]);
        }
        _successBlock = nil;
        _failureBlock = nil;
    }];
}

-(void)PATCHrequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@",APP_DOMAIN,method];
    _successBlock = success;
    _failureBlock = failure;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    if(withAuth){
        [manager.requestSerializer setValue:[[AGThisUser currentUser] getUserAuthToken] forHTTPHeaderField:kAuthToken];
    }
    
    [manager PATCH:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(_successBlock){
            _successBlock(responseObject,nil);
        }
        _successBlock = nil;
        _failureBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"ERROR!!%@",operation.responseObject);
        NSLog(@"ERROR: %@",operation.response);
        if(error.code == kNoInternetConnectionCode){
            NSLog(@"No internet connection!");
        }
        if(_failureBlock){
            _failureBlock(error, [self getErrorStringFrom:operation]);
        }
        _successBlock = nil;
        _failureBlock = nil;
    }];
}

-(NSString*)getErrorStringFrom:(AFHTTPRequestOperation*)operation{
    NSArray *errors = [operation.responseObject objectForKey:@"errors"];
    NSMutableString *err = [NSMutableString new];
    if(errors){
        for(NSString *errSt in errors){
            [err appendFormat:@"%@, ",errSt];
        }
    }
    NSString *errorString;
    if(err.length > 0){
        errorString = [err substringToIndex:err.length-2];
    } else {
        errorString = err;
    }
    return errorString;
}
@end
