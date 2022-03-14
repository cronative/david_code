//
//  AGApi.h
//  ViralVet
//
//  Created by Andrey Golovin on 27.10.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^AGApiSuccesCompletion)(id response, id wrongObject);
typedef void (^AGApiFailureCompletion)(NSError* error, NSString *errorString);

@interface AGApi : NSObject

@property (nonatomic, copy) AGApiSuccesCompletion successBlock;
@property (nonatomic, copy) AGApiFailureCompletion failureBlock;

-(void)uploadPhotoWithMethod:(NSString*)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth data:(NSData*)data photoKey:(NSString*)photoKey success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure;
-(void)POSTrequestWith:(NSString*)url parameters:(NSDictionary*)parameters success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure;
-(void)POSTrequestWithMethod:(NSString*)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure;

-(void)DELETErequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure;

-(void)GETrequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure;

-(void)PUTrequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure;

-(void)PATCHrequestWithMethode:(NSString *)method parameters:(NSDictionary*)parameters withAuthorization:(BOOL)withAuth success:(AGApiSuccesCompletion)success failure:(AGApiFailureCompletion)failure;
@end
