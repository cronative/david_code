//
//  Constants.h
//  ViralVet
//
//  Created by Andrey Golovin on 27.10.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ApplicationOpenGoogleAuthNotification @"ApplicationOpenGoogleAuthNotification"
#define HideAllHuds @"HideAllHUDS"

#define IS_BIG_PHONE (([UIScreen mainScreen].bounds.size.height > 568.)?YES:NO)
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define NEED_TUTORIAL @"needTutorial"
typedef NS_ENUM(NSInteger, TestimonialType){
    NullType,
    TextTestimonial,
    AudioTestimonial,
    VideoTestimonial,
};

//VIMEO OAUTH
extern NSString *const kVimeoOauthToken;
extern NSString *const kVimeoOauthTokenSecret;
extern NSString *const kVimeoDidReciveOauthTokens;

//Youtube
extern NSString *const kYoutubeDidReciveOauthTokens;


//GOOGLE+
extern NSString * const kGoogleClientId;
extern NSString *const kGoogleSecret;
//
//Fonts
extern NSString *const kAwesomeFont;
extern NSString *const kHelveticaNeueLight;
extern NSString *const kHelveticaNeueMedium;
extern NSString *const kHelveticaNeueBold;
extern NSString *const kHelveticaNeueRegular;
extern NSString *const kHelveticaNeueLightItalic;

//Fonts//
extern CGFloat const kAnimationSpeed;
extern NSString *const kDeviceToken;
////

extern NSString *const kJsonObjectKey;
extern NSString *const kEmail;
extern NSString *const kPassword;
extern NSString *const kAuthToken;
extern NSString *const kGoogleId;

extern NSString *const kConfirmPassword;
extern NSString *const kSource;
extern NSString *const kPhoneId;

extern NSString *const kVideoIntro;
extern NSString *const kResult;

//Profile
extern NSString *const kMerchantEmail;
extern NSString *const kMerchantName;
extern NSString *const kCompanyName;
extern NSString *const kCountry;
extern NSString *const kState;
extern NSString *const kPostalCode;
extern NSString *const kPhoneNumber;
extern NSString *const kFirstName;
extern NSString *const kLastName;
extern NSString *const kAddress;
extern NSString *const kCity;
extern NSString *const kWebsite;
extern NSString *const kTinyurl;
extern NSString *const kAccountType;
extern NSString *const kBusinessCategoryId;
extern NSString *const kGoogleCloudFileName;
extern NSString *const kGooglId;
extern NSString *const kIsRated;
extern NSString *const kIsYoutubeDefault;
extern NSString *const kLimitRecords;
extern NSString *const kPhonId;
extern NSString *const kPurchaseDate;
extern NSString *const kRateNotificDate;
extern NSString *const kVideoAvatar;
extern NSString *const kYoutubePassword;
extern NSString *const kYoutubeUsername;
/////////

//Storage
extern NSString *const kStorageId;
extern NSString *const kLogoPath;
extern NSString *const kRegistrationURL;
extern NSString *const kSmallLogoPath;
extern NSString *const kStorageName;
extern NSString *const kRecords;
//Upload storage
extern NSString *const kVssID;
extern NSString *const kLoginVSS;
extern NSString *const kPasswordVSS;
extern NSString *const kTokenVSS;
extern NSString *const kSecretVSS;
extern NSString *const kEnabled;
/////////

//Add Record keys
extern NSString *const krPhoneId;
extern NSString *const krTitle;
extern NSString *const krDescription;
extern NSString *const krTextBody;
extern NSString *const krUrl;
extern NSString *const krDeviceFilePath;
extern NSString *const krKeywords;
extern NSString *const krCompanyName;
extern NSString *const krWebsite;
extern NSString *const krCustomer;
extern NSString *const krPhoneNumber;
extern NSString *const krCustomerEmail;
extern NSString *const krGoogleCloudFileName;
extern NSString *const krRecordType;
extern NSString *const krPicturePath;
//Notifications
extern NSString *const kPopToMain;


//Business categories
#define GetCategoryByID(enum) [@[@"Arts & Entertainment", @"Automotive", @"Business & Professional Services", @"Clothing & Accessories", @"Community & Government", @"Computers & Electronics", @"Construction & Contractors", @"Education", @"Food & Dining", @"Health & Medicine", @"Home & Garden", @"Industry & Agriculture", @"Media & Communications", @"Personal Care & Services", @"Real Estate", @"Shopping", @"Sports & Recreation", @"Travel & Transportation"] objectAtIndex:enum]
#define GetIdByCategory(category) [@[@"Arts & Entertainment", @"Automotive", @"Business & Professional Services", @"Clothing & Accessories", @"Community & Government", @"Computers & Electronics", @"Construction & Contractors", @"Education", @"Food & Dining", @"Health & Medicine", @"Home & Garden", @"Industry & Agriculture", @"Media & Communications", @"Personal Care & Services", @"Real Estate", @"Shopping", @"Sports & Recreation", @"Travel & Transportation"] indexOfObject:[NSString stringWithFormat:@"%s",category]]
@interface Constants : NSObject

@end
