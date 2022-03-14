//
//  AGStorageCell.h
//  VocalReferences
//
//  Created by Andrey Golovin on 30.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGStorageCellDelegate <NSObject>

-(void)saveChangesForStorageAtIndexPath:(NSIndexPath *)indexPath;
-(void)saveStorageOnOffAtIndexPath:(NSIndexPath *)indexPath;
-(void)linkAccountPressed:(NSIndexPath*)indexPath;

@end

@interface AGStorageCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) id <AGStorageCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *storageIcon;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UILabel *storageText;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *content;
@property (nonatomic, strong) NSString *regURL;
@property (nonatomic, strong) NSIndexPath *indexPath;

-(void)youtubeCell;
-(void)defaultCell;

@end
