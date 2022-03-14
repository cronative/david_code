//
//  YSSubscriptionUpdater.h
//  YardSign
//
//  Created by Andrey Golovin on 03.04.14.
//  Copyright (c) 2014 Jelvix. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEASONAL_SUBSCR @"com.vocalreferences.paidversion.1month"
#define YEARLY_SUBSCR @"com.vocalreferences.paidversion.12month"

@protocol AGSubscriptionDelegate <NSObject>
-(void)didByMonthWithToken:(NSString *)token;
-(void)didByYearWithToken:(NSString *)token;
-(void)didCancel;
@end

@interface AGSubscriptionUpdater : NSObject<JXApiDelegate>

+(AGSubscriptionUpdater*)sharedUpdater;

@property (nonatomic, weak) id <AGSubscriptionDelegate> delegate;

-(void)buyMonthSubscription;
-(void)buyYearSubscription;

@end
