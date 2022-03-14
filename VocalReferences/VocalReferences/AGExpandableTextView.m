//
//  AGExpandableTextView.m
//  ViralVet
//
//  Created by Andrey Golovin on 01.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGExpandableTextView.h"

@interface AGExpandableTextView(){
    int currentKeyboardHeight;
    BOOL isAnimatingRotation;
    BOOL isKeyboardVisible;
    CGPoint _originTemp;
}



@end

@implementation AGExpandableTextView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.layer.masksToBounds = YES;
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        
        _originTemp = self.frame.origin;
        
        if (!_textView) _textView = [[UITextView alloc]init];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _textView.delegate = self;
        
        _textView.bounces = NO;
        
        _textView.font = [UIFont fontWithName:kHelveticaNeueLight size:18.f];
        _textView.textColor = [UIColor darkGrayColor];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.returnKeyType = UIReturnKeyDone;
        [self addSubview:_textView];
        
    }
    return self;
}

- (void) removeFromSuperview {
    [_placeholderLabel removeFromSuperview];
    _placeholderLabel = nil;
    
    [_textView removeFromSuperview];
    _textView.text = nil;
    _textView.delegate = nil;
    _textView = nil;

    _maxY = nil;
    _maxCharacters = nil;
    
    [super removeFromSuperview];
}

#pragma mark TEXT VIEW DELEGATE

- (void) textViewDidBeginEditing:(UITextView *)textView {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //if (![textView.text isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    //}
    
    [self resizeView];

}

- (void) textViewDidChange:(UITextView *)textView {
    
    if (![textView.text isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    }
    else {
        _placeholderLabel.hidden = NO;
    }
    
    [self resizeView];

}

- (void) textViewDidChangeSelection:(UITextView *)textView {
    [self resizeView];

}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _textView.contentOffset = CGPointMake(0, 0);
    if(_delegate && [_delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
        [_delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    if([text isEqualToString:@"\n"]){
        if (![textView.text isEqualToString:@""]) {
            _placeholderLabel.hidden = YES;
        }
        else {
            _placeholderLabel.hidden = NO;
        }
        [textView resignFirstResponder];
    }
        
    
    if(_delegate && [_delegate respondsToSelector:@selector(textViewCharacterLeft:)]){
        NSInteger charLeft = (_maxCharacters.intValue - (textView.text.length + (text.length - range.length)));
        if(charLeft < 0){
            charLeft = 0;
        }
        [_delegate textViewCharacterLeft:charLeft];
    }
    if (_maxCharacters) {
        return textView.text.length + (text.length - range.length) <= _maxCharacters.intValue;
    }
    else return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    self.autoresizingMask = UIViewAutoresizingNone;
    _textView.autoresizingMask = UIViewAutoresizingNone;
    return YES;
}
#pragma mark TEXT VIEW RESIZE | ALIGN

- (void) resizeView {
    CGFloat inputStartingPoint;
    CGFloat maxHeight;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        if (isKeyboardVisible) {
            inputStartingPoint = ScreenWidth() - currentKeyboardHeight;
            
        }
        else inputStartingPoint = ScreenWidth();
    }
    else {
        if (isKeyboardVisible) {
            inputStartingPoint = ScreenHeight() - currentKeyboardHeight;
            
        }
        else inputStartingPoint = ScreenHeight();
    }
    
    if (isKeyboardVisible) maxHeight = inputStartingPoint - _maxY.intValue;
    else {
        
        // I'd rather not use constants (162, 216) but it seems to be necessary in case a hardware keyboard is active
        
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            int adjustment = 162; // landscape keyboard height
            maxHeight = ScreenWidth() - adjustment - _maxY.intValue;
        }
        else {
            int adjustment = 216; // portrait keyboard height
            maxHeight = ScreenHeight() - adjustment - _maxY.intValue;
        }
    }
    
    
    NSString * content = _textView.text;
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:content attributes:@{ NSFontAttributeName : _textView.font, NSStrokeColorAttributeName : [UIColor darkTextColor]}];
    
    CGFloat width = _textView.bounds.size.width - 10; // whatever your desired width is
    // 10 less than our target because it seems to frame better
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGFloat height = rect.size.height;
    
    if ([_textView.text hasSuffix:@"\n"]) {
        height = height + _textView.font.lineHeight;
    }
    
    int originalHeight = 30; // starting chat input height
    int offset = originalHeight - _textView.font.lineHeight;
    int targetHeight = height + offset + 6; // should this be plus 12? it works with 6 but I 
    if (targetHeight > maxHeight) targetHeight = maxHeight;
    else if (targetHeight < 40) targetHeight = 40;
    
    //[UIView animateWithDuration:kAnimationSpeed animations:^{
        self.frame = CGRectMake(_originTemp.x, _originTemp.y, self.frame.size.width, targetHeight);
   // }];
    if(_delegate && [_delegate respondsToSelector:@selector(textViewDidChangeHeight:)]){
        [_delegate textViewDidChangeHeight:targetHeight];
    }
    
    _textView.contentOffset = CGPointMake(0, 0);
    // in case they backspaced and we need to block send
}

- (UILabel *) placeholderLabel {
    if (!_placeholderLabel) {
        CGRect frame = _textView.frame;
        frame.origin.x = frame.origin.x+3;
        _placeholderLabel = [[UILabel alloc]initWithFrame:frame];
        _placeholderLabel.userInteractionEnabled = NO;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:18.f];
        _placeholderLabel.textColor = [UIColor colorWithRed:188./255. green:190./255. blue:192./255. alpha:1.];
        _placeholderLabel.autoresizingMask = UIViewAutoresizingNone;
        [self insertSubview:_placeholderLabel aboveSubview:_textView];
    }
    
    return _placeholderLabel;
}
@end
