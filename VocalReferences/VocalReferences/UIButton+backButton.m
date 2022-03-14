//
//  UIButton+backButton.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "UIButton+backButton.h"

@implementation UIButton (backButton)

-(void)thisIsBackButtonWithOptionalFont:(UIFont*)font andColor:(UIColor *)color{
    UIFont *awesome = [UIFont fontWithName:kAwesomeFont size:18.];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:awesome}];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"Back" attributes:@{NSFontAttributeName:((font)?font:[UIFont fontWithName:kHelveticaNeueLight size:18.])}];
    [str1 appendAttributedString:str2];
    [str1 addAttribute:NSForegroundColorAttributeName value:((color)?color:[UIColor whiteColor]) range:NSMakeRange(0, str1.string.length)];
    [self setAttributedTitle:str1 forState:UIControlStateNormal];
}

@end
