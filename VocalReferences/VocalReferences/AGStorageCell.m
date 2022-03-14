//
//  AGStorageCell.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGStorageCell.h"
@interface AGStorageCell()

@property (weak, nonatomic) IBOutlet UILabel *line1;
@property (weak, nonatomic) IBOutlet UILabel *line2;
@property (weak, nonatomic) IBOutlet UILabel *line3;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;

@end

@implementation AGStorageCell

- (void)awakeFromNib {
    [_saveButton applyAwesomeFontWithSize:22.f];
    CGRect temp = _content.frame;
    temp.size.width = SCREEN_WIDTH;
    _content.frame = temp;
    
    CGRect sw = _switcher.frame;
    sw.origin.x = SCREEN_WIDTH-sw.size.width-10;
    _switcher.frame = sw;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchPressed:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(saveStorageOnOffAtIndexPath:)]){
        [_delegate saveStorageOnOffAtIndexPath:_indexPath];
    }
}

- (IBAction)createAccountPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_regURL]];
}

- (IBAction)saveChanges:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(saveChangesForStorageAtIndexPath:)]){
        [_delegate saveChangesForStorageAtIndexPath:_indexPath];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)youtubeCell{
    _storageText.textAlignment = NSTextAlignmentCenter;
    
    CGRect temp = _storageText.frame;
    temp.origin.y = 124;
    _storageText.frame = temp;
    
    [_linkButton setHidden:NO];
    [_line3 setHidden:NO];
    [_line1 setHidden:YES];
    [_line2 setHidden:YES];
    [_username setHidden:YES];
    [_password setHidden:YES];
}

-(void)defaultCell{
    _storageText.textAlignment = NSTextAlignmentLeft;
    
    CGRect temp = _storageText.frame;
    temp.origin.y = 120;
    _storageText.frame = temp;
    
    [_linkButton setHidden:YES];
    [_line3 setHidden:YES];
    [_line1 setHidden:NO];
    [_line2 setHidden:NO];
    [_username setHidden:NO];
    [_password setHidden:NO];
}

- (IBAction)linkPressed:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(linkAccountPressed:)]){
        [_delegate linkAccountPressed:_indexPath];
    }
}
@end
