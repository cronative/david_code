//
//  AGSettingsCell.h
//  VocalReferences
//
//  Created by Andrey Golovin on 28.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGSettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *arrorw;
@property (weak, nonatomic) IBOutlet UILabel *rightText;
@property (weak, nonatomic) IBOutlet UILabel *leftText;
@property (weak, nonatomic) IBOutlet UIView *content;
@end
