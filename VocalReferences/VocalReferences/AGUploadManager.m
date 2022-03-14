//
//  AGUploadManager.m
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGUploadManager.h"

NSString *const kObjectUploadedNotification = @"objectUploadedNotific";
NSString *const kManagerDidFinishUploadingNotification = @"managerFinishUploading";

@interface AGUploadManager()<JXApiDelegate>{
    NSInteger _uploadingIndex;
}

@property (nonatomic) BOOL uploading;
@property (nonatomic, strong) NSMutableArray *testimonials;
@property (nonatomic, strong) Testimonial *uploadingTestimonial;
@end

@implementation AGUploadManager

+(AGUploadManager*)uploader{
    static AGUploadManager *uploader = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        uploader = [[AGUploadManager alloc] init];
    });
    return uploader;
}

-(BOOL)uploading{
    return _uploading;
}

-(void)uploadTestimonials:(NSArray *)testimonials{
    _uploading = YES;
    _testimonials = [NSMutableArray arrayWithArray:testimonials];
    if(_testimonials.count == 0) return;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _uploadingIndex = 0;
    [self uploadTestimonial:_testimonials[_uploadingIndex]];
}

-(void)addTestimonialToUpload:(NSArray *)testimonials{
    [_testimonials addObjectsFromArray:testimonials];
}

-(void)uploadTestimonial:(Testimonial*)testimonial{
    _uploadingTestimonial = testimonial;
    AGApi *getLink = [AGApi new];
    [getLink POSTrequestWith:GET_CLOUD_LINK parameters:nil success:^(id response, id wrongObject) {
        NSLog(@"Success CLOUD: %@",response);
        NSString *path = response[@"link"];
        [self uploadWithLink:path andTestimonial:testimonial];
    } failure:^(NSError *error, NSString *errorString) {
        NSLog(@"Failure cloud: %@",error);
        [self stopUploading];
    }];
}

-(void)uploadWithLink:(NSString *)url andTestimonial:(Testimonial*)testimonial{
    NSLog(@"Upload start!");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSInteger type = testimonial.type.integerValue;
    
    if(type == TextTestimonial && !testimonial.image) {
        [self addTestimonial:testimonial withMainURL:@"" imageUrl:@""];
    } else {
        __block NSString *filename;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            switch (type) {
                case AudioTestimonial:
                    filename = [NSString stringWithFormat:@"%@.mp3",url.lastPathComponent];
                    [formData appendPartWithFormData:[@"audio" dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
                    [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"filename"];
                    [formData appendPartWithFileData:testimonial.data name:@"file" fileName:filename mimeType:@"audio/mp3"];
                    break;
                case VideoTestimonial:
                    filename = [NSString stringWithFormat:@"%@.mp4",url.lastPathComponent];
                    NSLog(@"FILENAME: %@",filename);
                    [formData appendPartWithFormData:[@"video" dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
                    [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"filename"];
                    [formData appendPartWithFileData:testimonial.data name:@"file" fileName:filename mimeType:@"video/mp4"];
                    break;
                case TextTestimonial:
                    filename = [NSString stringWithFormat:@"%@.jpg",url.lastPathComponent];
                    [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
                    [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"filename"];
                    [formData appendPartWithFileData:testimonial.image name:@"file" fileName:filename mimeType:@"image/jpeg"];
                    
                    break;
                default:
                    break;
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Uploading error!" message:@"Cloud storage is not working!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [error show];
            [self stopUploading];
            NSLog(@"Success: \n%@\n%@\n%@\n%@\n%@", operation.responseString,operation.responseObject,operation.responseData, responseObject, operation.response);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"operation: %@",operation.responseString);
            NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];

            NSString *file = json[@"filePath"];
            file = [file lastPathComponent];
            switch (type) {
                case AudioTestimonial:{
                    if(testimonial.image){
                        NSString *resultURL = [NSString stringWithFormat:@"audio/%@",file];
                        [self uploadImageForAudioOrVideoTestimonial:testimonial mainURL:resultURL];
                    } else {
                        NSString *resultURL = [NSString stringWithFormat:@"audio/%@",file];
                        [self addTestimonial:testimonial withMainURL:resultURL imageUrl:nil];
                    }
                    break;
                }
                case VideoTestimonial:{
                    NSString *resultURL = [NSString stringWithFormat:@"video/%@",file];
                    [self uploadImageForAudioOrVideoTestimonial:testimonial mainURL:resultURL];
                    //[self addTestimonial:testimonial withMainURL:resultURL imageUrl:@""];
                    break;
                }
                case TextTestimonial:{
                    NSString *resultURL = [NSString stringWithFormat:@"%@image/%@",GOOGLE_STORAGE,file];
                    [self addTestimonial:testimonial withMainURL:nil imageUrl:resultURL];
                    break;
                }
                default:
                    break;
            }
        }];
    }
}

-(void)uploadImageForAudioOrVideoTestimonial:(Testimonial*)testimonial mainURL:(NSString *)mainURL{
    AGApi *getLink = [AGApi new];
    [getLink POSTrequestWith:GET_CLOUD_LINK parameters:nil success:^(id response, id wrongObject) {
        NSLog(@"Success CLOUD: %@",response);
        NSString *path = response[@"link"];
        __block NSString *filename;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager POST:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            filename = [NSString stringWithFormat:@"%@.jpg",path.lastPathComponent];
            [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
            [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"filename"];
            [formData appendPartWithFileData:testimonial.image name:@"file" fileName:filename mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"operation: %@",operation.responseString);
            NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            
            NSString *file = json[@"filePath"];
            file = [file lastPathComponent];
            NSString *resultURL = [NSString stringWithFormat:@"%@image/%@",GOOGLE_STORAGE,file];
            [self addTestimonial:testimonial withMainURL:mainURL imageUrl:resultURL];
        }];
    } failure:^(NSError *error, NSString *errorString) {
        NSLog(@"Failure cloud: %@",error);
        [self stopUploading];
    }];
    
}

-(void)addTestimonial:(Testimonial*)testimonial withMainURL:(NSString *)mainUrl imageUrl:(NSString *)imageUrl{
    JXApiRequest *upload = [JXApiRequest new];
    upload.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",ADD_RECORD,[[AGThisUser currentUser] getUserAuthToken]];
    [upload requestWithDomain:APP_DOMAIN methode:method parameters:[self getParametersForTestimonial:testimonial mainUrl:mainUrl imageUrl:imageUrl] photoContent:nil videoContent:nil audioContent:nil];
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"Response: %@",response);
    BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
    if(result){
        [_uploadingTestimonial remove];
        [_testimonials removeObjectAtIndex:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:kObjectUploadedNotification object:nil];
        if(_testimonials.count > 0){
            [self uploadTestimonial:_testimonials[_uploadingIndex]];
        } else {
            [self stopUploading];
        }
        
    } else {
        [self stopUploading];
    }
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"Record adding failed!: %@",connectionError);
    [self stopUploading];
}

-(NSDictionary *)getParametersForTestimonial:(Testimonial*)testimonial mainUrl:(NSString*)mainUrl imageUrl:(NSString*)imageUrl{
    NSString *image = [NSString stringWithFormat:@"image/%@",[imageUrl lastPathComponent]];
    NSDictionary *params = @{krPhoneId:[self randomString],
                             krTitle:(testimonial.title)?testimonial.title:@"",
                             krDescription:(testimonial.descript)?testimonial.descript:@"",
                             krTextBody:(testimonial.text)?testimonial.text:@"",
                             krUrl:@"",
                             krDeviceFilePath:@"filepath",
                             krKeywords:(testimonial.keywords)?testimonial.keywords:@"",
                             krCompanyName:(testimonial.companyName)?testimonial.companyName:@"",
                             krWebsite:(testimonial.website)?testimonial.website:@"",
                             krCustomer:(testimonial.customer)?testimonial.customer:@"",
                             krPhoneNumber:(testimonial.phoneNumber)?testimonial.phoneNumber:@"",
                             krCustomerEmail:(testimonial.customerEmail)?testimonial.customerEmail:@"",
                             krGoogleCloudFileName:(mainUrl)?mainUrl:image,
                             krRecordType:(testimonial.type)?testimonial.type:@"",
                             krPicturePath:(imageUrl)?imageUrl:@""};
    NSLog(@"PARAMS: %@",params);
    return @{kJsonObjectKey:params.JSON};
}



-(NSString *)randomString{
    int len = 10;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void)stopUploading{
    _uploading = NO;
    [_testimonials removeAllObjects];
    _uploading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerDidFinishUploadingNotification object:nil];
}

-(BOOL)isUploadingNowTestimonial:(Testimonial*)testimonial{
    for(Testimonial *test in _testimonials){
        if([testimonial isEqual:test]){
            return YES;
        }
    }
    return NO;
}
@end
