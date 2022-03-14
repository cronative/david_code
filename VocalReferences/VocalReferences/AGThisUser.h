//
//  AGThisUser.h
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGThisUser : NSObject

+(AGThisUser*)currentUser;

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString * companyName;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * postalCode;
@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSString * businessCategory;
@property (nonatomic, strong) NSString * tinyurl;
@property (nonatomic, strong) NSString * accountType;
@property (nonatomic, strong) NSString * googleCloudFileName;
@property (nonatomic, strong) NSString * googlId;
@property (nonatomic, strong) NSString * isRated;
@property (nonatomic, strong) NSString * isYoutubeDefault;
@property (nonatomic, strong) NSString * limitRecords;
@property (nonatomic, strong) NSString * phonId;
@property (nonatomic, strong) NSString * purchaseDate;
@property (nonatomic, strong) NSString * rateNotificDate;
@property (nonatomic, strong) NSString * videoAvatar;
@property (nonatomic, strong) NSString * youtubePassword;
@property (nonatomic, strong) NSString * youtubeUsername;
@property (nonatomic, strong) NSString * youtubeLinkedTo;
@property (nonatomic, strong) NSString * merchantEmail;
@property (nonatomic, strong) NSString * merchantName;

@property (nonatomic) BOOL isLinked;


-(void)removeUser;
-(NSString *)getUserAuthToken;
-(NSString *)userEmail;

-(void)updateProfile;

@end
