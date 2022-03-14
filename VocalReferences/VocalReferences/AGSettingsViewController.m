//
//  AGSettingsViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 31.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGSettingsViewController.h"
#import "AGSettingsCell.h"

@interface AGSettingsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation AGSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    
    _menuItems = @[@"Profile",@"Storage Options",@"Change Password",@"My Page",@"VR Version",@"OS Version",@"Account Type",@"Logout"];
}

-(void)viewWillAppear:(BOOL)animated{
    [_tableView reloadData];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AGSettingsCell *cell = (AGSettingsCell*)[tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    
    cell.leftText.text = _menuItems[indexPath.row];
    if((indexPath.row <= 2) || (indexPath.row == 6)){
        [cell.arrorw setHidden:NO];
    } else {
        [cell.arrorw setHidden:YES];
    }
    if((indexPath.row <= 2) || (indexPath.row == 7)){
        [cell.rightText setHidden:YES];
    } else {
        [cell.rightText setHidden:NO];
        switch (indexPath.row) {
            case 3:
                cell.rightText.text = [AGThisUser currentUser].tinyurl;
                break;
            case 4:
                cell.rightText.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
                break;
            case 5:
                cell.rightText.text = [[UIDevice currentDevice] systemVersion];
                break;
            case 6:{
                NSInteger accType = [AGThisUser currentUser].accountType.integerValue;
                switch (accType) {
                    case 0:
                        cell.rightText.text = @"Basic";
                        break;
                    case 1:
                        cell.rightText.text = @"Month";
                        break;
                    case 4:
                        cell.rightText.text = @"Annual";
                        break;
                    default:
                        cell.rightText.text = @"Basic";
                        break;
                }
                
                break;
            }
            default:
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"profileViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:{
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"storageOption"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:{
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"changePasswordViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AGThisUser currentUser].tinyurl]];
            break;
        case 6:{
            NSLog(@"Account type!");
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"upgradeViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 7:
            [[AGThisUser currentUser] removeUser];
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        default:
            break;
    }
    
}

@end
