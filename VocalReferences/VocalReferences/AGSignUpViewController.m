//
//  AGSignUpViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGSignUpViewController.h"
#import <GooglePlus/GPPSignIn.h>
#import <GoogleOpenSource/GTLPlusConstants.h>
#import <GooglePlus/GPPSignInButton.h>
#import "MBProgressHUD.h"
#import "OpenUDID.h"
#import "AGMainViewController.h"

@interface AGSignUpViewController ()<GPPSignInDelegate, JXApiDelegate, UITextFieldDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;

@end

@implementation AGSignUpViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    [self setFonts];
    [self initSignInGoogle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideHud) name:HideAllHuds object:nil];
}


-(void)hideHud{
    [HUD hide:YES];
}

-(void)initSignInGoogle{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.clientID = kGoogleClientId;
    signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin,
                     nil];
    signIn.delegate = self;
    [signIn setShouldFetchGooglePlusUser:YES];
    [signIn setShouldFetchGoogleUserEmail:YES];
    [signIn setShouldFetchGoogleUserID:YES];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"By creating an account you hereby agree to abide by our terms and conditions." attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueLight size:15.]}];
    [string addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:[string.string rangeOfString:@"terms and conditions."]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, string.string.length)];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:kHelveticaNeueLight size:14.] range:NSMakeRange(0, string.string.length)];
    [_termsButton setAttributedTitle:string forState:UIControlStateNormal];
    _termsButton.titleLabel.numberOfLines = 3;
    _termsButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    UIFont *awesome = [UIFont fontWithName:kAwesomeFont size:30.];
    UIFont *helvetica = [UIFont fontWithName:kHelveticaNeueMedium size:18.f];
    NSMutableAttributedString *icon = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:awesome}];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Sign in with Google" attributes:@{NSFontAttributeName:helvetica,NSBaselineOffsetAttributeName:[NSNumber numberWithFloat:4.f]}];
    [icon appendAttributedString:title];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, icon.string.length)];
    [_signInButton setAttributedTitle:icon forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_email resignFirstResponder];
    [_password resignFirstResponder];
    [_confirmPassword resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - API

- (IBAction)createAccountPressed:(id)sender {
    if(![self checkFieldsOK]) return;
    
    [HUD show:YES];
    JXApiRequest *signup = [JXApiRequest new];
    signup.delegate = self;
    [[AGThisUser currentUser] setEmail:_email.text];
    NSDictionary *params = @{kEmail:_email.text,kPassword:_password.text,kConfirmPassword:_confirmPassword.text, kSource:@"iosapp",kPhoneId:[OpenUDID value]};
    [signup requestWithDomain:APP_DOMAIN methode:SIGN_UP parameters:@{kJsonObjectKey:params.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"RESPONSE: %@",response);
    [HUD hide:YES];
    BOOL result = [NSString stringWithFormat:@"%@",response[kResult]].boolValue;
    if(result){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:NEED_TUTORIAL];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *authToken = [NSString stringWithFormat:@"%@",response[kAuthToken]];
        [[AGThisUser currentUser] setAuthToken:authToken];
        [[AGThisUser currentUser] updateProfile];
        AGMainViewController *main = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self.navigationController pushViewController:main animated:YES];
    } else {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"User with this `Email` has already registered." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
    }
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"ConnectionError:%@",connectionError);
    [HUD hide:YES];
}

-(BOOL)checkFieldsOK{
    if(![_email.text isCorrectEmail]){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Incorrect email!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return NO;
    }
    if(_password.text.length < 6){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The password must be at least 6 characters!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return NO;
    }
    if(![_password.text isEqualToString:_confirmPassword.text]){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Passwords do not match!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return NO;
    }
    return YES;
}

#pragma mark - Google+
- (IBAction)googlePlusPressed:(id)sender {
    [HUD show:YES];
    [[GPPSignIn sharedInstance] authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        [HUD hide:YES];
    } else {
        NSLog(@"%@\n%@",[GPPSignIn sharedInstance].userID,[GPPSignIn sharedInstance].userEmail);
        JXApiRequest *login = [JXApiRequest new];
        login.delegate = self;
        [[AGThisUser currentUser] setEmail:[GPPSignIn sharedInstance].userEmail];
        NSDictionary *params = @{kEmail:[GPPSignIn sharedInstance].userEmail,kGoogleId:[GPPSignIn sharedInstance].userID};
        [login requestWithDomain:APP_DOMAIN methode:LOGIN_SOCIAL parameters:@{kJsonObjectKey:params.JSON} photoContent:nil videoContent:nil audioContent:nil];
    }
}

@end
