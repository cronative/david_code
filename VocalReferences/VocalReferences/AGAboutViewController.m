//
//  AGAboutViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 05.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGAboutViewController.h"

@interface AGAboutViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation AGAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.vocalreferences.com/home/aboutus"]];
    [_webView loadRequest:req];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
