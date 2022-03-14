//
//  AGReferenceDetailsViewController.h
//  VocalReferences
//
//  Created by Andrey Golovin on 23.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGReferenceDetailsViewController : UIViewController

@property (nonatomic) NSInteger testimonialType;
@property (nonatomic, strong) NSURL *recordedVideo;
@property (nonatomic, strong) NSData *recordedAudio;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSString *text;

@end
