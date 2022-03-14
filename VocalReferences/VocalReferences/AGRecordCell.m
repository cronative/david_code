//
//  AGRecordCell.m
//  VocalReferences
//
//  Created by Andrey Golovin on 05.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGRecordCell.h"

@interface AGRecordCell(){
    
}

@property (weak, nonatomic) IBOutlet UIView *content;

@end

@implementation AGRecordCell

- (void)awakeFromNib {
    CGRect temp = _content.frame;
    temp.size.width = [UIScreen mainScreen].bounds.size.width - 20;
    _content.frame = temp;
    [[_playButton imageView] setContentMode:UIViewContentModeScaleAspectFit];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)startUploadingAnimation{
    [_activity startAnimating];
    [_uploadIcon setHidden:YES];
}
-(void)stopUploadingAnimation{
    [_activity stopAnimating];
    [_uploadIcon setHidden:NO];
}

- (IBAction)playCellPressed:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(cellPlayPressedAtIndexPath:)]){
        [_delegate cellPlayPressedAtIndexPath:_indexPath];
    }
}
@end
