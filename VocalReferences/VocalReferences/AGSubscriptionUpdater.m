//
//  YSSubscriptionUpdater.m
//  YardSign
//
//  Created by Andrey Golovin on 03.04.14.
//  Copyright (c) 2014 Jelvix. All rights reserved.
//

#import "AGSubscriptionUpdater.h"
#import "MKStoreManager.h"

@implementation AGSubscriptionUpdater{
    MBProgressHUD *HUD;
    JXApiRequest *_buySubscription;
    NSTimer *_checkTimer;
    BOOL checked;
}

static AGSubscriptionUpdater *updater = NULL;
+(AGSubscriptionUpdater*)sharedUpdater{
    if(!updater || updater == NULL){
        updater = [[AGSubscriptionUpdater alloc] init];
        
    }
     NSLog(@"PURCHASABLE OBJECTS: %@",[[MKStoreManager sharedManager] subscriptionProducts]);
    return updater;
}

-(void)buyMonthSubscription{
    if([[[MKStoreManager sharedManager] purchasableObjects] count]>0){
        NSLog(@"SHOW!!!");
        [[MKStoreManager sharedManager] buyFeature:SEASONAL_SUBSCR onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
            NSLog(@"Purchased == %@;\n%@\n%@",purchasedFeature,purchasedReceipt,availableDownloads);
            NSString *receipt = [purchasedReceipt base64EncodedStringWithOptions:0];
            NSLog(@"Month receipt: %@",receipt);
            if(_delegate && [_delegate respondsToSelector:@selector(didByMonthWithToken:)]){
                [_delegate didByMonthWithToken:receipt];
            }
        } onCancelled:^{
            if(_delegate && [_delegate respondsToSelector:@selector(didCancel)]){
                [_delegate didCancel];
            }
            NSLog(@"Purchase canceled");
        }];
    }
}
-(void)buyYearSubscription{
    if([[[MKStoreManager sharedManager] purchasableObjects] count]>0){
        [[MKStoreManager sharedManager] buyFeature:YEARLY_SUBSCR onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
            NSLog(@"Purchased == %@;\n%@\n%@",purchasedFeature,purchasedReceipt,availableDownloads);
            NSString *receipt = [purchasedReceipt base64EncodedStringWithOptions:0];
            NSLog(@"Year receipt: %@",receipt);
            if(_delegate && [_delegate respondsToSelector:@selector(didByYearWithToken:)]){
                [_delegate didByYearWithToken:receipt];
            }
        } onCancelled:^{
            NSLog(@"Purchase canceled");
            if(_delegate && [_delegate respondsToSelector:@selector(didCancel)]){
                [_delegate didCancel];
            }
        }];
    }
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"Response: %@",response);
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"Error: %@",connectionError);
}
@end
