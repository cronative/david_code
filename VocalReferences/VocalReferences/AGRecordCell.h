//
//  AGRecordCell.h
//  VocalReferences
//
//  Created by Andrey Golovin on 05.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGRecordCellDelegate <NSObject>

-(void)cellPlayPressedAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface AGRecordCell : UITableViewCell

@property (nonatomic, weak) id <AGRecordCellDelegate>delegate;

@property (nonatomic) BOOL isLocal;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *uploadIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteIcon;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) NSIndexPath *indexPath;

-(void)startUploadingAnimation;
-(void)stopUploadingAnimation;

@end
