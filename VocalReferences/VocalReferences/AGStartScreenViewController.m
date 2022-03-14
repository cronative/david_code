//
//  ViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGStartScreenViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AGMainViewController.h"

@interface AGStartScreenViewController ()

@end

@implementation AGStartScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadVideoIntro];
}

-(void)viewDidAppear:(BOOL)animated{
    if([[AGThisUser currentUser] getUserAuthToken]){
        [[AGThisUser currentUser] updateProfile];
        AGMainViewController *main = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self.navigationController pushViewController:main animated:YES];
    }
}

-(void)loadVideoIntro{
    AGApi *intro = [AGApi new];
    [intro POSTrequestWithMethod:GET_INTRO parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
        NSLog(@"RESPONSE: %@",response);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *videoLink = [NSString stringWithFormat:@"%@",response[kVideoIntro]];
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:videoLink]];
            [_webView loadRequest:req];
        });
    } failure:^(NSError *error, NSString *errorString) {
        NSLog(@"Error: %@",error);
    }];
}

-(void)setFonts{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"New User?" attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueLight size:15.]}];
    [string addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:NSMakeRange(0, string.string.length)];
    [_label setAttributedText:string];
//    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:@"Create a New Account - It's Free!" attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueLight size:15.]}];
//    [string2 addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:NSMakeRange(0, string2.string.length)];
//    [string2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.200 green:0.710 blue:0.898 alpha:1.000] range:NSMakeRange(0, string2.string.length)];
//    [_signUpButton setAttributedTitle:string2 forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
