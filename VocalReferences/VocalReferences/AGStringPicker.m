//
//  AGSpecieChoose.m
//  ViralVet
//
//  Created by Andrey Golovin on 09.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGStringPicker.h"

static CGFloat const pickerHeight = 246.f;
static CGFloat const offset = 15.f;
static CGFloat const buttonWidth = 75.f;
static CGFloat const buttonHeight = 44.f;

@interface AGStringPicker()<UIPickerViewDataSource, UIPickerViewDelegate>{
    CGRect _selfFrame;
    NSInteger _selectedSpecie;
}

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation AGStringPicker

-(id)initWithFrame:(CGRect)frame{
    return nil;
}

-(id)init{
    self = [super initWithFrame:CGRectZero];
    if(self){
        _selfFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, pickerHeight);
        self.frame = _selfFrame;
        self.backgroundColor = [UIColor whiteColor];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, buttonHeight)];
        title.backgroundColor = [UIColor blackColor];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.text = @"Business Category";
        title.font = [UIFont fontWithName:kHelveticaNeueMedium size:17.];
        [self addSubview:title];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
        cancel.frame = CGRectMake(offset, 0, buttonWidth, buttonHeight);
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueRegular size:17.]];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cancel addTarget:self action:@selector(cancelDidPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancel];
        
        UIButton *done = [UIButton buttonWithType:UIButtonTypeSystem];
        done.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-buttonWidth-offset, 0, buttonWidth, buttonHeight);
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [done.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueMedium size:17.f]];
        done.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [done addTarget:self action:@selector(doneDidPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:done];
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, buttonHeight, [UIScreen mainScreen].bounds.size.width, pickerHeight-buttonHeight)];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
    }
    return self;
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _items.count;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 35.f;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *title = _items[row];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueRegular size:23.], NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    return string;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectedSpecie = row;
}
#pragma mark - Show / hide

-(void)showPickerInView:(UIView*)view withItems:(NSArray *)items{
    _items = [NSArray arrayWithArray:items];
    [view addSubview:self];
    [_pickerView reloadAllComponents];
    
    _showed = YES;
    CGRect temp = _selfFrame;
    temp.origin.y = [UIScreen mainScreen].bounds.size.height-temp.size.height;
    NSLog(@"FRAME: %@",NSStringFromCGRect(temp));
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        self.frame = temp;
    }];
}

-(void)hide{
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        self.frame = _selfFrame;
    } completion:^(BOOL finished) {
        _items = nil;
        _pickerView = nil;
        _showed = NO;
        [self removeFromSuperview];
    }];
}

#pragma mark - Buttons actions

-(void)cancelDidPressed{
    [self hide];
}

-(void)doneDidPressed{
    if(_delegate && [_delegate respondsToSelector:@selector(doneWithString:)]){
        [_delegate doneWithString:_items[_selectedSpecie]];
        [self hide];
    }
}
@end
