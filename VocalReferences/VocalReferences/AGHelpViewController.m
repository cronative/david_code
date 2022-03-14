//
//  AGHelpViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 31.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGHelpViewController.h"

@interface AGHelpViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AGHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.vocalreferences.com/wp/support/"]];
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
