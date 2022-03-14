//
//  AGTermsViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 13.04.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGTermsViewController.h"

@interface AGTermsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation AGTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.vocalreferences.com/home/termsandconditions"]];
    [_webView loadRequest:req];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
