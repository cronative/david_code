//
//  AGRecord.h
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNeedToUpdateListOfRecords;
extern NSString *const kRecordEdited;

@interface AGRecord : NSObject<JXApiDelegate>

@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *correctedUrl;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *customer;
@property (nonatomic, strong) NSString *customerEmail;
@property (nonatomic, strong) NSString *descript;
@property (nonatomic, strong) NSString *googleCloudLink;
@property (nonatomic, strong) NSString *recordId;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *picturePath;
@property (nonatomic, strong) NSString *previewImage;
@property (nonatomic) NSInteger recordType;
@property (nonatomic) NSInteger status;
@property (nonatomic, strong) NSString *textBody;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *vssId;
@property (nonatomic, strong) NSString *vssThumbnail;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *countViews;

-(instancetype)initWithDictionary:(NSDictionary *)dict;
-(void)remove;
-(void)setFavorite;
-(void)shareInViewController:(UIViewController*)viewController;
-(void)sendEmailInViewController:(UIViewController*)viewController;
-(void)sendSMSInViewController:(UIViewController*)viewController;
-(void)edit;

-(void)setViewController:(UIViewController*)viewController;
-(void)postToFacebook;
-(void)refreshInterfaceBasedOnSignIn;
-(void)initLinkedIn;
-(void)postToTwitter;
@end
