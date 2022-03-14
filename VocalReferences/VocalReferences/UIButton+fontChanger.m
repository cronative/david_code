//
//  UIButton+fontChanger.m
//  VocalReferences
//
//  Created by Andrey Golovin on 20.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "UIButton+fontChanger.h"

@implementation UIButton (fontChanger)

-(void)applyAwesomeFontWithSize:(CGFloat)fontSize{
    [self.titleLabel setFont:[UIFont fontWithName:kAwesomeFont size:fontSize]];
}

-(void)applyAwesomeFontWithSize:(CGFloat)fontSize color:(UIColor *)color{
    [self.titleLabel setFont:[UIFont fontWithName:kAwesomeFont size:fontSize]];
    [self setTitleColor:color forState:UIControlStateNormal];
}

@end
