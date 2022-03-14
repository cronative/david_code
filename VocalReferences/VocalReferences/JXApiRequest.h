//
//  JXApiRequest.h
//  JXApiRequest
//
//  Created by Andrey Golovin on 04.01.14.
//  Copyright (c) 2014 Jelvix. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol JXApiDelegate;

@interface JXApiRequest : NSObject

@property (nonatomic, weak) id<JXApiDelegate>delegate;

@property (nonatomic) NSInteger tag;

-(void)requestWithDomain:(NSString*)domain
                 methode:(NSString*)methode
              parameters:(NSDictionary*)parameters
            photoContent:(NSDictionary*)photoContent
            videoContent:(NSDictionary*)videoContent
            audioContent:(NSDictionary*)audioContent;
-(void)requestWithDomain:(NSString*)domain
                 methode:(NSString*)methode
              parameters:(NSDictionary*)parameters
             dataContent:(NSDictionary*)dataContent;
@end

@protocol JXApiDelegate <NSObject>

-(void)apiRequest:(JXApiRequest*)request didReciveResponse:(NSDictionary*)response;
-(void)apiRequest:(JXApiRequest*)request finishWithConnectionError:(NSError*)connectionError;
@optional
-(void)apiRequest:(JXApiRequest*)request didReciveData:(NSData *)data;
-(void)showIndicator:(BOOL)show;
@end
