//
//  AGChangePasswordViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGChangePasswordViewController.h"

@interface AGChangePasswordViewController ()<UITextFieldDelegate, JXApiDelegate, UIAlertViewDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@end

@implementation AGChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    [self setFonts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    [_saveButton applyAwesomeFontWithSize:22.f];
    
    [[_saveButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_saveButton setImage:[[UIImage imageNamed:@"disk@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_saveButton setTintColor:[UIColor whiteColor]];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)savePressed:(id)sender {
    if(_oldPassword.text.length == 0){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill in your old password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return;
    }
    if(_password.text.length == 0){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill in a new password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return;
    }
    if(_confirmPassword.text.length == 0){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill in a confirm password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return;
    }
    if(_password.text.length < 6){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The password must be at least 6 characters!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return;
    }
    if(![_password.text isEqualToString:_confirmPassword.text]){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Passwords do not match!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        return;
    }
    [HUD show:YES];
    
    JXApiRequest *change = [JXApiRequest new];
    change.delegate = self;
    NSString *methode = [NSString stringWithFormat:@"%@%@",CHANGE_PASS,[[AGThisUser currentUser] getUserAuthToken]];
    [change requestWithDomain:APP_DOMAIN methode:methode parameters:[self parameters] photoContent:nil videoContent:nil audioContent:nil];
}

-(NSDictionary *)parameters{
    NSDictionary *json = @{@"password":_password.text,@"confirm_password":_confirmPassword.text,@"old_password":_oldPassword.text};
    return @{kJsonObjectKey:json.JSON};
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"Change pass response: %@",response);
    BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
    [HUD hide:YES];
    if(result){
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Password successfully changed." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
    } else {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error!" message:[self getErrorStringFrom:response] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"Error: %@",connectionError);
    [HUD hide:YES];
}

-(NSString*)getErrorStringFrom:(NSDictionary*)operation{
    NSArray *errors = [operation objectForKey:@"errors"];
    NSMutableString *err = [NSMutableString new];
    if(errors){
        for(NSString *errSt in errors.firstObject){
            [err appendFormat:@"%@, ",errSt];
        }
    }
    NSString *errorString;
    if(err.length > 0){
        errorString = [err substringToIndex:err.length-2];
    } else {
        errorString = err;
    }
    return errorString;
}
@end
