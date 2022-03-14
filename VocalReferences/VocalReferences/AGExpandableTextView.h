//
//  AGExpandableTextView.h
//  ViralVet
//
//  Created by Andrey Golovin on 01.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMacros.h"

@protocol AGExpandableTextDelegate <NSObject>

-(void)textViewDidChangeHeight:(CGFloat)height;

@optional
-(void)textViewCharacterLeft:(NSInteger)characterLeft;
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end

@interface AGExpandableTextView : UIView <UITextViewDelegate>

@property (nonatomic, weak) id <AGExpandableTextDelegate> delegate;

@property (strong, nonatomic) NSNumber * maxCharacters;
@property (strong, nonatomic) UILabel * placeholderLabel;
@property (strong, nonatomic) NSNumber * maxY;
@property (strong, nonatomic) UITextView * textView;

@end
