//
//  AGThisUser.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGThisUser.h"
@implementation AGThisUser

-(id)init{
    return nil;
}

-(id)initCustom{
    self = [super init];
    return self;
}

+(AGThisUser*)currentUser{
    static AGThisUser *currentUser = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        currentUser = [[AGThisUser alloc] initCustom];
    });
    return currentUser;
}

-(void)setEmail:(NSString *)email{
    _email = email;
    if(_email){
        [[NSUserDefaults standardUserDefaults] setObject:_email forKey:kEmail];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)setAuthToken:(NSString*)authToken{
    _authToken = authToken;
    if(_authToken){
        [[NSUserDefaults standardUserDefaults] setObject:_authToken forKey:kAuthToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)removeUser{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAuthToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)getUserAuthToken{
    NSString * auth = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthToken];
    if(auth){
        _authToken = auth;
        return auth;
    }
    return nil;
}
-(NSString *)userEmail{
    NSString * email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
    if(email){
        return email;
    }
    return nil;
}

-(void)initWithDictionary:(NSDictionary *)dict{
    if(dict){
        _merchantEmail = [[NSString stringWithFormat:@"%@",dict[kMerchantEmail]] stringWithoutNull];
        _merchantName = [[NSString stringWithFormat:@"%@",dict[kMerchantName]] stringWithoutNull];
        _companyName = [NSString stringWithFormat:@"%@",dict[kCompanyName]];
        _country = [NSString stringWithFormat:@"%@",dict[kCountry]];
        _state = [NSString stringWithFormat:@"%@",dict[kState]];
        _postalCode = [NSString stringWithFormat:@"%@",dict[kPostalCode]];
        _phoneNumber = [NSString stringWithFormat:@"%@",dict[kPhoneNumber]];
        _firstName = [NSString stringWithFormat:@"%@",dict[kFirstName]];
        _lastName = [NSString stringWithFormat:@"%@",dict[kLastName]];
        _address = [NSString stringWithFormat:@"%@",dict[kAddress]];
        _city = [NSString stringWithFormat:@"%@",dict[kCity]];
        _website = [NSString stringWithFormat:@"%@",dict[kWebsite]];
        _businessCategory = [NSString stringWithFormat:@"%@",dict[kBusinessCategoryId]];
        _tinyurl = [NSString stringWithFormat:@"%@",dict[kTinyurl]];
        _accountType = [NSString stringWithFormat:@"%@",dict[kAccountType]];
        if(_accountType.integerValue == -1){
            _accountType = @"0";
        }
        _googleCloudFileName = [NSString stringWithFormat:@"%@",dict[kGoogleCloudFileName]];
        _googlId = [NSString stringWithFormat:@"%@",dict[kGooglId]];
        _isRated = [NSString stringWithFormat:@"%@",dict[kIsRated]];
        _isYoutubeDefault = [NSString stringWithFormat:@"%@",dict[kIsYoutubeDefault]];
        _limitRecords = [NSString stringWithFormat:@"%@",dict[kLimitRecords]];
        _phonId = [NSString stringWithFormat:@"%@",dict[kPhonId]];
        _purchaseDate = [NSString stringWithFormat:@"%@",dict[kPurchaseDate]];
        _rateNotificDate = [NSString stringWithFormat:@"%@",dict[kRateNotificDate]];
        _videoAvatar = [NSString stringWithFormat:@"%@",dict[kVideoAvatar]];
        _youtubePassword = [NSString stringWithFormat:@"%@",dict[kYoutubePassword]];
        _youtubeUsername = [NSString stringWithFormat:@"%@",dict[kYoutubeUsername]];
        _youtubeLinkedTo = [[NSString stringWithFormat:@"%@",dict[@"youtube_linked_to"]] stringWithoutNull];
        _isLinked = [NSString stringWithFormat:@"%@",dict[@"isLinked"]].boolValue;
    }
}

-(void)updateProfile{
    AGApi *update = [AGApi new];
    NSString *methode = [NSString stringWithFormat:@"%@%@",GET_PROFILE,_authToken];
    [update GETrequestWithMethode:methode parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
        NSLog(@"User profile: %@",response);
        BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
        if(result){
            [self initWithDictionary:response[kJsonObjectKey]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userUpdated" object:nil];
    } failure:^(NSError *error, NSString *errorString) {
        NSLog(@"Update profile failed!, %@",error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userUpdated" object:nil];
    }];
}
@end
