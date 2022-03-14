//
//  AGLoginViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGLoginViewController.h"
#import <GooglePlus/GPPSignIn.h>
#import <GoogleOpenSource/GTLPlusConstants.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GPPSignInButton.h>
#import "MBProgressHUD.h"
#import "AGMainViewController.h"

static NSInteger const kResetPassAPI = 10;

@interface AGLoginViewController ()<GPPSignInDelegate, JXApiDelegate, UITextFieldDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (retain, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation AGLoginViewController

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
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"Reset password now" attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueLight size:15.]}];
    [string addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:NSMakeRange(0, string.string.length)];
    [_resetButton setAttributedTitle:string forState:UIControlStateNormal];
    
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
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - API

- (IBAction)loginPressed:(id)sender {
    if(![self checkFieldsOK]) return;
    
    [HUD show:YES];
    JXApiRequest *login = [JXApiRequest new];
    login.delegate = self;
    [[AGThisUser currentUser] setEmail:_email.text];
    NSDictionary *params = @{kEmail:_email.text,kPassword:_password.text};
    [login requestWithDomain:APP_DOMAIN methode:LOGIN parameters:@{kJsonObjectKey:params.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"RESPONSE: %@",response);
    [HUD hide:YES];
    if(request.tag == kResetPassAPI){
        BOOL result = [NSString stringWithFormat:@"%@",response[kResult]].boolValue;
        if(result){
            UIAlertView *success = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your new password has been sent to e-mail!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [success show];
        } else {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"This email does not exist!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [error show];
        }
    } else {
        BOOL result = [NSString stringWithFormat:@"%@",response[kResult]].boolValue;
        if(result){
            NSString *authToken = [NSString stringWithFormat:@"%@",response[kAuthToken]];
            [[AGThisUser currentUser] setAuthToken:authToken];
            [[AGThisUser currentUser] updateProfile];
            AGMainViewController *main = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self.navigationController pushViewController:main animated:YES];
        } else {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email and password don't match!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [error show];
        }
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
    if(_password.text.length == 0){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Incorrect password!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
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

    NSLog(@"Received error %@ and auth object %@ expired: %@",error, auth, auth.expirationDate);
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

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
    } else {
        // Authentication succeeded
    }
}
#pragma mark - Reset password

- (IBAction)resetPasswordPressed:(id)sender {
    if(![_email.text isCorrectEmail]){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Incorrect email!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return;
    }
    [HUD show:YES];
    JXApiRequest *reset = [JXApiRequest new];
    reset.delegate = self;
    reset.tag = kResetPassAPI;
    NSDictionary *params = @{kEmail:_email.text};
    [reset requestWithDomain:APP_DOMAIN methode:RESET_PASSWORD parameters:@{kJsonObjectKey:params.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

@end
