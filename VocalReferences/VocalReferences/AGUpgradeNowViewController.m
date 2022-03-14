//
//  AGUpgradeNowViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 12.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGUpgradeNowViewController.h"
#import "AGSubscriptionUpdater.h"

#define kMonthRequest 2101
#define kAnnualRequest 2102


@interface AGUpgradeNowViewController ()<AGSubscriptionDelegate, JXApiDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation AGUpgradeNowViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [AGSubscriptionUpdater sharedUpdater].delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    CGFloat contentHeight;
    if(SCREEN_HEIGHT == 480.f){
        contentHeight = 484;
    } else {
        contentHeight = _scrollView.frame.size.height;
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, contentHeight);

    [AGSubscriptionUpdater sharedUpdater].delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userUpdated)
                                                 name:@"userUpdated"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)monthPressed:(id)sender {
    NSInteger accountType = [AGThisUser currentUser].accountType.integerValue;
    if(accountType == 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You already purchase this." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    } else if(accountType == 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You already purchase annual subscription." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [HUD show:YES];
    [HUD hide:YES afterDelay:30.f];
    [[AGSubscriptionUpdater sharedUpdater] buyMonthSubscription];
}

- (IBAction)annualPressed:(id)sender {
    NSInteger accountType = [AGThisUser currentUser].accountType.integerValue;
    if(accountType == 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You already purchase this." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [HUD show:YES];
    [HUD hide:YES afterDelay:30.f];
    [[AGSubscriptionUpdater sharedUpdater] buyYearSubscription];
}

-(void)didByMonthWithToken:(NSString *)token{
    JXApiRequest *verify = [JXApiRequest new];
    verify.delegate = self;
    verify.tag = kMonthRequest;
    [verify requestWithDomain:APP_DOMAIN methode:VERIFY_RECEIPT parameters:@{kJsonObjectKey:@{@"purchace_original_json":token}.JSON} photoContent:nil videoContent:nil audioContent:nil];

}

-(void)didByYearWithToken:(NSString *)token{
    JXApiRequest *verify = [JXApiRequest new];
    verify.delegate = self;
    verify.tag = kAnnualRequest;
    [verify requestWithDomain:APP_DOMAIN methode:VERIFY_RECEIPT parameters:@{kJsonObjectKey:@{@"purchace_original_json":token}.JSON} photoContent:nil videoContent:nil audioContent:nil];

}

-(void)didCancel{
    [HUD hide:YES];
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    if(request.tag == kMonthRequest){
        NSLog(@"PURCHASE MONTH VERIFIER: %@",response);
        BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
        if(result){
            BOOL status = [NSString stringWithFormat:@"%@",response[@"verified"][@"status"]].boolValue;
            if(status == 0){
                [self buyMonth];
            } else {
                [self purchaseError];
            }
        } else {
            [self buyMonth];
        }
    } else if(request.tag == kAnnualRequest){
        NSLog(@"PURCHASE ANNUAL VERIFIER: %@",response);
        BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
        if(result){
            BOOL status = [NSString stringWithFormat:@"%@",response[@"verified"][@"status"]].boolValue;
            if(status == 0){
                [self buyAnnual];
            } else {
                [self purchaseError];
            }
        } else {
            [self buyAnnual];
        }
    } else {
        NSLog(@"RESPONSE: %@",response);
        [HUD hide:YES afterDelay:20.f];
        [[AGThisUser currentUser] updateProfile];
    }
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"ERROR: %@",connectionError);
    [HUD hide:YES];
}

-(void)buyMonth{
    [HUD show:YES];
    JXApiRequest *buy = [JXApiRequest new];
    buy.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",UPGRADE,[[AGThisUser currentUser] getUserAuthToken]];
    [buy requestWithDomain:APP_DOMAIN methode:method parameters:@{kJsonObjectKey:@{@"id_itunes":@"00000000",@"account_type":@"1",@"description":@"1 month"}.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

-(void)buyAnnual{
    [HUD show:YES];
    JXApiRequest *buy = [JXApiRequest new];
    buy.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",UPGRADE,[[AGThisUser currentUser] getUserAuthToken]];
    [buy requestWithDomain:APP_DOMAIN methode:method parameters:@{kJsonObjectKey:@{@"id_itunes":@"00000000",@"account_type":@"4",@"description":@"1 year"}.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

-(void)userUpdated{
    [HUD hide:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)purchaseError{
    [HUD hide:YES];
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Purchase verification failed!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [error show];
}
@end
