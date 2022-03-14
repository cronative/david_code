//
//  JXApiRequest.m
//  JXApiRequest
//
//  Created by Andrey Golovin on 04.01.14.
//  Copyright (c) 2014 Jelvix. All rights reserved.
//

#import "JXApiRequest.h"

#import "NSDictionary_JSONExtensions.h"

@implementation JXApiRequest

-(void)requestWithDomain:(NSString *)domain
                 methode:(NSString*)methode
              parameters:(NSDictionary *)parameters
            photoContent:(NSDictionary *)photoContent
            videoContent:(NSDictionary *)videoContent
            audioContent:(NSDictionary *)audioContent
{
    @try {

        if([_delegate respondsToSelector:@selector(showIndicator:)]){
            [_delegate showIndicator:YES];
        }
        
        NSString *url = [NSString stringWithFormat:@"%@%@",domain,methode];
        
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0f];
        [theRequest setHTTPMethod:@"POST"];
        NSString *boundary = @"1BEF0A57BE110FD467A";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [theRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        
        NSArray *textDictonaryKeys=[parameters allKeys];
        
        NSMutableData *body = [NSMutableData data];
        
        for(NSString *key in textDictonaryKeys){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n%@\r\n",[parameters objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSArray *photoDictonaryKeys=[photoContent allKeys];
        
        for(NSString *key in photoDictonaryKeys){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n",key,key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[photoContent objectForKey:key]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSArray *videoDictionaryKey=[videoContent allKeys];
        
        for(NSString *key in videoDictionaryKey){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.mp4\"\r\n",key,key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: video/mp4\r\n\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            [body appendData:[videoContent objectForKey:key]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSArray *audioDictonaryKeys=[audioContent allKeys];
        
        for(NSString *key in audioDictonaryKeys){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.mp3\"\r\n",key,key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: audio/mp3\r\n\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[audioContent objectForKey:key]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        
        [theRequest setHTTPBody:body];
        
        //NSLog(@"\n%@ \n",[[NSString alloc]initWithData:body encoding:NSUTF8StringEncoding]);
        
        [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if([_delegate respondsToSelector:@selector(showIndicator:)]){
                [_delegate showIndicator:NO];
            }
            if(connectionError){
                NSLog(@"Error!");
                if(_delegate && [_delegate respondsToSelector:@selector(apiRequest:finishWithConnectionError:)]){
                    [_delegate apiRequest:self finishWithConnectionError:connectionError];
                }
            } else {
                NSLog(@"Response: %@",response);
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Result string - %@",result);
                NSError *theError = NULL;
                NSDictionary *answer = [NSDictionary dictionaryWithJSONString:result error:&theError];
                if(_delegate && [_delegate respondsToSelector:@selector(apiRequest:didReciveResponse:)]){
                    [_delegate apiRequest:self didReciveResponse:answer];
                }
                if(!answer || answer == nil){
                    if(_delegate && [_delegate respondsToSelector:@selector(apiRequest:didReciveData:)]){
                        [_delegate apiRequest:self didReciveData:data];
                    }
                }
            }
        }];
    }
    @catch (NSException *exception) {
        
        NSLog(@"%@ %@",exception.name,exception.description);
        
    }
    @finally {}
}

-(void)requestWithDomain:(NSString*)domain
                 methode:(NSString*)methode
              parameters:(NSDictionary*)parameters
             dataContent:(NSDictionary*)dataContent{
    @try {
        
        if([_delegate respondsToSelector:@selector(showIndicator:)]){
            [_delegate showIndicator:YES];
        }
        
        NSString *url = [NSString stringWithFormat:@"%@%@",domain,methode];
        
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0f];
        [theRequest setHTTPMethod:@"POST"];
        NSString *boundary = @"1BEF0A57BE110FD467A";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [theRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSArray *textDictonaryKeys=[parameters allKeys];
        
        NSMutableData *body = [NSMutableData data];
        
        for(NSString *key in textDictonaryKeys){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n%@\r\n",[parameters objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSArray *dataDictonaryKeys=[dataContent allKeys];
        
        for(NSString *key in dataDictonaryKeys){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: audio/mp3\r\n\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[dataContent objectForKey:key]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"BODY == %@",body);
        [theRequest setHTTPBody:body];
        
        NSLog(@"\n%@ \n",[[NSString alloc]initWithData:body encoding:NSUTF8StringEncoding]);
        
        [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if([_delegate respondsToSelector:@selector(showIndicator:)]){
                [_delegate showIndicator:NO];
            }
            if(connectionError){
                NSLog(@"Error!");
                if(_delegate && [_delegate respondsToSelector:@selector(apiRequest:finishWithConnectionError:)]){
                    [_delegate apiRequest:self finishWithConnectionError:connectionError];
                }
            } else {
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Result string - %@",result);
                NSError *theError = NULL;
                NSDictionary *answer = [NSDictionary dictionaryWithJSONString:result error:&theError];
                if(_delegate && [_delegate respondsToSelector:@selector(apiRequest:didReciveResponse:)]){
                    [_delegate apiRequest:self didReciveResponse:answer];
                }
                if(!answer || answer == nil){
                    if(_delegate && [_delegate respondsToSelector:@selector(apiRequest:didReciveData:)]){
                        [_delegate apiRequest:self didReciveData:data];
                    }
                }
            }
        }];
    }
    @catch (NSException *exception) {
        
        NSLog(@"%@ %@",exception.name,exception.description);
        
    }
    @finally {}
}

@end
