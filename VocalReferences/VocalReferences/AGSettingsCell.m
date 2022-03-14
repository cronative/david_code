//
//  AGSettingsCell.m
//  VocalReferences
//
//  Created by Andrey Golovin on 28.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGSettingsCell.h"
@implementation AGSettingsCell

- (void)awakeFromNib {
    CGRect temp = _content.frame;
    temp.size.width = SCREEN_WIDTH;
    _content.frame = temp;
    [_arrorw setFont:[UIFont fontWithName:kAwesomeFont size:18.]];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
