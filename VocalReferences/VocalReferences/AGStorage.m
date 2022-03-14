//
//  AGStorage.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGStorage.h"

NSString *const kVSSUploadedSuccess = @"vssUploadedSuc";
NSString *const kVSSUploadedFailed = @"vssUploadedFai";
@interface AGStorage()<JXApiDelegate>

@end

@implementation AGStorage

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if(self){
        _storageId = [NSString stringWithFormat:@"%@",dictionary[kStorageId]];
        _vssId = [NSString stringWithFormat:@"%@",dictionary[kVssID]];
        _logoPath = [NSString stringWithFormat:@"%@",dictionary[kLogoPath]];
        _registrationUrl = [NSString stringWithFormat:@"%@",dictionary[kRegistrationURL]];
        _smallLogoPath = [NSString stringWithFormat:@"%@",dictionary[kSmallLogoPath]];
        _storageName = [NSString stringWithFormat:@"%@",dictionary[kStorageName]];
        _token = [NSString stringWithFormat:@"%@",dictionary[kTokenVSS]];
        _tokenSecret = [NSString stringWithFormat:@"%@",dictionary[kSecretVSS]];
        _login = [NSString stringWithFormat:@"%@",dictionary[kLoginVSS]];
        _password = [NSString stringWithFormat:@"%@",dictionary[kPasswordVSS]];
        _isEnabled = [NSString stringWithFormat:@"%@",dictionary[kEnabled]].boolValue;
        _userEmail = [NSString stringWithFormat:@"%@",dictionary[@"user_email"]];
    }
    return self;
}

-(void)saveStorage{
    JXApiRequest *upload = [JXApiRequest new];
    upload.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",SET_VSS,[[AGThisUser currentUser] getUserAuthToken]];
    [upload requestWithDomain:APP_DOMAIN methode:method parameters:[self parametersForUpload] photoContent:nil videoContent:nil audioContent:nil];
}

-(void)editStorage{
    JXApiRequest *upload = [JXApiRequest new];
    upload.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",EDIT_VSS,[[AGThisUser currentUser] getUserAuthToken]];
    [upload requestWithDomain:APP_DOMAIN methode:method parameters:[self parametersForUpload] photoContent:nil videoContent:nil audioContent:nil];
}

-(NSDictionary *)parametersForUpload{
    NSString *enabled = [NSString stringWithFormat:@"%d",_isEnabled];
    NSDictionary *content = @{kVssID:_vssId, kLoginVSS:_login, kPasswordVSS:_password,kTokenVSS:_token, kSecretVSS:_tokenSecret, kEnabled:enabled};
    NSLog(@"Request: %@",@{kJsonObjectKey:content.JSON});
    return @{kJsonObjectKey:content.JSON};
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"Upload success: %@",response);
    [[NSNotificationCenter defaultCenter] postNotificationName:kVSSUploadedSuccess object:nil];
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"Upload error: %@",connectionError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kVSSUploadedFailed object:nil];
}
@end
