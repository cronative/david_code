//
//  AGStorage.h
//  VocalReferences
//
//  Created by Andrey Golovin on 30.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const kVSSUploadedSuccess;
extern NSString *const kVSSUploadedFailed;
@interface AGStorage : NSObject

@property (nonatomic, strong) NSString *storageId;
@property (nonatomic, strong) NSString *vssId;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *logoPath;
@property (nonatomic, strong) NSString *registrationUrl;
@property (nonatomic, strong) NSString *smallLogoPath;
@property (nonatomic, strong) NSString *storageName;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *tokenSecret;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) BOOL isEnabled;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(void)saveStorage;
-(void)editStorage;

@end
