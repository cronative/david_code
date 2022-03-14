//
//  AGGoogleAuth.h
//  VocalReferences
//
//  Created by Andrey Golovin on 13.04.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGGoogleAuth : UIView

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

-(void)openUrl:(NSURL*)url;

@end
