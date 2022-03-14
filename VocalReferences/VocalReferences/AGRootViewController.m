//
//  AGRootViewController.m
//  ViralVet
//
//  Created by Andrey Golovin on 09.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGRootViewController.h"

@interface AGRootViewController ()
@property (nonatomic, strong) UIButton *hiddenButton;
@end

@implementation AGRootViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.bounds = [UIScreen mainScreen].bounds;
}

-(void)viewWillLayoutSubviews{
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.bounds = [UIScreen mainScreen].bounds;
}

@end
