//
//  AGEditViewController.h
//  VocalReferences
//
//  Created by Andrey Golovin on 10.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Testimonial.h"

@interface AGEditViewController : UIViewController

@property (nonatomic, strong) AGRecord *record;
@property (nonatomic, strong) Testimonial *testimonial;

@end
