//
//  AGSpecieChoose.h
//  ViralVet
//
//  Created by Andrey Golovin on 09.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGStringPickerDelegate <NSObject>

-(void)doneWithString:(NSString*)string;

@end

@interface AGStringPicker : UIView

@property (nonatomic, weak) id <AGStringPickerDelegate> delegate;

@property (nonatomic) BOOL showed;

-(void)showPickerInView:(UIView*)view withItems:(NSArray *)items;
-(void)hide;

@end
