//
//  AGMainViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 31.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AGMainViewController.h"
#import <MessageUI/MessageUI.h>
#import "AGRecordCell.h"
#import "AGRecordVideoViewController.h"
#import "AGReferenceDetailsViewController.h"
#import "Testimonial.h"
#import <AVFoundation/AVFoundation.h>
#import "AGUploadManager.h"
#import "AGSingleViewViewController.h"
#import "AGUploadedSingleViewViewController.h"
#import "AGEditViewController.h"
#import "AGSubscriptionUpdater.h"

#define kDeleteAlert 991

typedef NS_ENUM(NSInteger, AGMenuButtons){
    Settings,
    Help,
    AboutUs,
    RateApp,
    ShareApp,
    Upgrade,
    Logout,
};

typedef NS_ENUM(NSInteger, AGShareButtons) {
    Email,
    SMS,
};

static NSString *const kItunesLink = @"https://itunes.apple.com/us/app/vocalreferences/id543276764?mt=8";
static NSInteger const kMenuSheet = 1;
static NSInteger const kCellSheet = 2;
static NSInteger const kShareSheet = 3;

@interface AGMainViewController ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AGRecordCellDelegate, UIAlertViewDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) NSMutableArray *testimonials;
@property (nonatomic, strong) NSMutableArray *records;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSIndexPath *tempIndexPath;

@property (nonatomic, strong) UIImageView *slide;
@property (nonatomic, strong) UIImageView *slide2;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *linkButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@end

@implementation AGMainViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AGSubscriptionUpdater sharedUpdater];
    
    [AGVssManager manager];
    
    [self setFonts];
    
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popToMain)
                                                 name:kPopToMain
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTable)
                                                 name:kNeedToUpdateListOfRecords
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTable)
                                                 name:kObjectUploadedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:kVssDidLoadNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:kManagerDidFinishUploadingNotification
                                               object:nil];
    
    if([(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:NEED_TUTORIAL] boolValue]){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:NEED_TUTORIAL];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showTutorial];
    }
    
    [HUD show:YES];
}

-(void)showTutorial{
    _slide = [[UIImageView alloc] initWithFrame:self.view.frame];
    CGRect slide2Frame = self.view.frame;
    slide2Frame.origin.x = SCREEN_WIDTH;
    _slide2 = [[UIImageView alloc] initWithFrame:slide2Frame];
    _slide.userInteractionEnabled = YES;
    _slide2.userInteractionEnabled = YES;
    [self.view addSubview:_slide];
    [self.view addSubview:_slide2];

    if(SCREEN_HEIGHT == 480.){
        _slide.image = [UIImage imageNamed:@"1_vr_4"];
        _slide2.image = [UIImage imageNamed:@"2_vr_4"];
    } else if(SCREEN_HEIGHT == 568.){
        _slide.image = [UIImage imageNamed:@"1_vr_5"];
        _slide2.image = [UIImage imageNamed:@"2_vr_5"];
    } else if(SCREEN_HEIGHT == 667.f){
        _slide.image = [UIImage imageNamed:@"1_vr_6"];
        _slide2.image = [UIImage imageNamed:@"2_vr_6"];
    } else if(SCREEN_HEIGHT == 736.){
        _slide.image = [UIImage imageNamed:@"1_vr_6+"];
        _slide2.image = [UIImage imageNamed:@"2_vr_6+"];
    }

    _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT/2-60, 60, 100)];
    [_nextButton addTarget:self action:@selector(firstSlidePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
}

-(void)firstSlidePressed{
    [_nextButton setEnabled:NO];
    CGRect nS1f = _slide.frame;
    nS1f.origin.x = -SCREEN_WIDTH;
    CGRect nS2f = _slide2.frame;
    nS2f.origin.x = 0;
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        _slide.frame = nS1f;
        _slide2.frame = nS2f;
    } completion:^(BOOL finished) {
        [_nextButton setEnabled:YES];
    }];
    [_nextButton removeTarget:self action:@selector(firstSlidePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_nextButton addTarget:self action:@selector(secondSlidePressed) forControlEvents:UIControlEventTouchUpInside];
    _nextButton.frame = CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT/2+30, 60, 100);
    
    
    if(SCREEN_HEIGHT == 480.){
        _linkButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-90, SCREEN_WIDTH/2, 40)];
    } else if(SCREEN_HEIGHT == 568.){
        _linkButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-120, SCREEN_WIDTH/2, 40)];
    } else if(SCREEN_HEIGHT == 667.f){
       _linkButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-150, SCREEN_WIDTH/2, 40)];
    } else if(SCREEN_HEIGHT == 736.){
        _linkButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-160, SCREEN_WIDTH/2, 40)];
    }
    
    [_linkButton addTarget:self action:@selector(linkOnSlidePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_linkButton];
}

-(void)secondSlidePressed{
     [_nextButton removeFromSuperview];
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        _slide2.alpha = 0;
    } completion:^(BOOL finished) {
        [_slide2 removeFromSuperview];
        [_slide removeFromSuperview];
    }];
}

-(void)linkOnSlidePressed{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.vocalreferences.com"]];
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateTable];
    
    [self addLines];
}

-(void)addLines{
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(_audioButton.frame.size.width, _audioButton.frame.origin.y+8, 1, 28)];
    line.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:line];
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(_audioButton.frame.size.width+_videoButton.frame.size.width, _audioButton.frame.origin.y+8, 1, 28)];
    line2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:line2];
}

-(void)setFonts{
    _menuButton.titleLabel.font = [UIFont fontWithName:kAwesomeFont size:18.];
    _refreshButton.titleLabel.font = [UIFont fontWithName:kAwesomeFont size:18.];
    _uploadButton.titleLabel.font = [UIFont fontWithName:kAwesomeFont size:18.];
    _audioButton.titleLabel.font = [UIFont fontWithName:kAwesomeFont size:22];
    _videoButton.titleLabel.font = [UIFont fontWithName:kAwesomeFont size:22];
    _textButton.titleLabel.font = [UIFont fontWithName:kAwesomeFont size:22];
    
    [[_audioButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_audioButton setImage:[UIImage imageNamed:@"recordButton"] forState:UIControlStateNormal];
    [[_videoButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_videoButton setImage:[UIImage imageNamed:@"recordVideo"] forState:UIControlStateNormal];
    [[_textButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_textButton setImage:[UIImage imageNamed:@"recordText"] forState:UIControlStateNormal];
    
    _emptyLabel.text = @"No testimonials yet?\n Select a record type below to begin.";
}

-(void)popToMain{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)reloadTableView{
    [_tableView reloadData];
}

-(void)updateTable{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _testimonials = [NSMutableArray arrayWithArray:[Testimonial getAllTestimonialsForUserEmail:[[AGThisUser currentUser] userEmail]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            AGApi *getAll = [AGApi new];
            NSString *method = [NSString stringWithFormat:@"%@%@",GET_ALLRECORDS,[[AGThisUser currentUser] getUserAuthToken]];
            [getAll GETrequestWithMethode:method parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
                NSLog(@"ALL RECORDS: %@",response);
                BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
                if(result){
                    _records = [NSMutableArray new];
                    for(NSDictionary *dict in response[@"records"]){
                        AGRecord *record = [[AGRecord alloc] initWithDictionary:dict];
                        [_records addObject:record];
                    }
                    _records = [NSMutableArray arrayWithArray:[[_records reverseObjectEnumerator] allObjects]];
                }
                [HUD hide:YES];
                [_tableView reloadData];
            } failure:^(NSError *error, NSString *errorString) {
                NSLog(@"Error: %@",error);
                [HUD hide:YES];
                [_tableView reloadData];
            }];
            
        });
    });
}

- (IBAction)refreshPressed:(id)sender {
    [HUD show:YES];
    [self updateTable];
}

- (IBAction)uploadAllPressed:(id)sender {
    //if([self canAddRecord]){
    NSInteger limit = [AGThisUser currentUser].limitRecords.integerValue;
    if(limit >= _records.count+_testimonials.count){
        NSMutableArray *temp = [NSMutableArray new];
        for(Testimonial *testim in _testimonials){
            if(![[AGUploadManager uploader] isUploadingNowTestimonial:testim]){
                [temp addObject:testim];
            }
        }
        if(temp.count > 0){
            if([[AGUploadManager uploader] uploading]){
                [[AGUploadManager uploader] addTestimonialToUpload:temp];
                [_tableView reloadData];
            } else {
                [[AGUploadManager uploader] uploadTestimonials:temp];
                [_tableView reloadData];
            }
        }
    } else {
        [self canAddRecord];
    }
}

#pragma mark - Menu actions

- (IBAction)menuPressed:(id)sender {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Settings",@"Help",@"About Us",@"Rate App",@"Share App",@"Upgrade",@"Logout", nil];
    menu.tag = kMenuSheet;
    [menu showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == kMenuSheet){
        switch (buttonIndex) {
            case Settings:{
                UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                [self.navigationController pushViewController:vc animated:YES];
                NSLog(@"Settings pressed");
                break;
            }
            case Help:{
                UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"HelpViewController"];
                [self.navigationController pushViewController:vc animated:YES];
                NSLog(@"Help pressed");
                break;
            }
            case AboutUs:{
                NSLog(@"AboutUs pressed");
                UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"aboutViewController"];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case RateApp:{
                NSLog(@"Rate pressed");
                NSURL *rateURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=543276764&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"];
                [[UIApplication sharedApplication] openURL:rateURL];
                break;
            }
            case ShareApp:{
                NSLog(@"Share pressed");
                UIActionSheet *share = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"SMS", nil];
                share.tag = kShareSheet;
                [share showInView:self.view];
                break;
            }
            case Upgrade:{
                UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"upgradeViewController"];
                [self.navigationController pushViewController:vc animated:YES];
                NSLog(@"Upgrade pressed");
                break;
            }
            case Logout:
                NSLog(@"Logout pressed");
                [[AGThisUser currentUser] removeUser];
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    } else if(actionSheet.tag == kShareSheet){
        switch (buttonIndex) {
            case Email:
                NSLog(@"Share via Email");
                [self shareViaEmail];
                break;
            case SMS:
                NSLog(@"Share via SMS");
                [self shareViaSMS];
                break;
            default:
                break;
        }
    } else if(actionSheet.tag == kCellSheet){
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Delete"]){
            if([self canAddRecord]){
                if(_testimonials.count < _tempIndexPath.row+1){
                    if([AGThisUser currentUser].accountType.intValue == 0){
                        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Upgrade account" message:@"Please upgrade your account to add more testimonials." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Upgrade", nil];
                        error.tag = 1234;
                        [error show];
                        return;
                    }
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete record" message:@"Are you sure you wish to delete this record?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag = kDeleteAlert;
                [alert show];
            } else {
                return;
            }
        } else if([title isEqualToString:@"Upload"]){
            //if([self canAddRecord]){
            NSInteger limit = [AGThisUser currentUser].limitRecords.integerValue;
            if(limit >= _records.count+_testimonials.count){
                if(_testimonials.count >= _tempIndexPath.row+1){
                    Testimonial *testimon = _testimonials[_tempIndexPath.row];
                    if([[AGUploadManager uploader] isUploadingNowTestimonial:testimon]){
                        //testimonial is uploading
                    } else {
                        if([[AGUploadManager uploader] uploading]){
                            [[AGUploadManager uploader] addTestimonialToUpload:@[testimon]];
                            [_tableView reloadData];
                        } else {
                            [[AGUploadManager uploader] uploadTestimonials:@[testimon]];
                            [_tableView reloadData];
                        }
                    }
                }
            } else {
                [self canAddRecord];
            }
        } else if([title isEqualToString:@"Favorite"]){
            if(_testimonials.count >= _tempIndexPath.row+1){
                UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please upload testimonial before setting favorite." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [error show];
            } else {
                [HUD show:YES];
                AGRecord *record = _records[_tempIndexPath.row-_testimonials.count];
                [record setFavorite];
            }
        } else if([title isEqualToString:@"Refresh"]){
            [self refreshPressed:nil];
        } else if([title isEqualToString:@"Email"]){
            if(_testimonials.count >= _tempIndexPath.row+1){
                UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please upload testimonial before sending it via email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [error show];
                return;
            }
            AGRecord *record = _records[_tempIndexPath.row-_testimonials.count];
            [record sendEmailInViewController:self];
        } else if([title isEqualToString:@"SMS"]){
            if(_testimonials.count >= _tempIndexPath.row+1){
                UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please upload testimonial before sending it via sms." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [error show];
                return;
            }
            AGRecord *record = _records[_tempIndexPath.row-_testimonials.count];
            [record sendSMSInViewController:self];
        } else if([title isEqualToString:@"Share"]){
            if(_testimonials.count >= _tempIndexPath.row+1){
                UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please upload testimonial before sharing." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [error show];
                return;
            }
            AGRecord *record = _records[_tempIndexPath.row-_testimonials.count];
            [record shareInViewController:self];
        } else if([title isEqualToString:@"View"]){
            if(_testimonials.count >= _tempIndexPath.row+1){
                Testimonial *testimon = _testimonials[_tempIndexPath.row];
                AGSingleViewViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"singleViewController"];
                vc.testimonial = testimon;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                AGRecord *record = _records[_tempIndexPath.row-_testimonials.count];
                AGUploadedSingleViewViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"uploadSingleViewController"];
                vc.testimonial = record;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else if([title isEqualToString:@"Edit"]){
            if(_testimonials.count >= _tempIndexPath.row+1){
                Testimonial *testimon = _testimonials[_tempIndexPath.row];
                AGEditViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"editViewController"];
                vc.testimonial = testimon;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                AGRecord *record = _records[_tempIndexPath.row-_testimonials.count];
                AGEditViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"editViewController"];
                vc.record = record;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

-(void)cellPlayPressedAtIndexPath:(NSIndexPath *)indexPath{
    if(_testimonials.count >= indexPath.row+1){
        Testimonial *testimon = _testimonials[indexPath.row];
        AGSingleViewViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"singleViewController"];
        vc.testimonial = testimon;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AGRecord *record = _records[indexPath.row-_testimonials.count];
        AGUploadedSingleViewViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"uploadSingleViewController"];
        vc.testimonial = record;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Share App

-(void)shareViaEmail{
    NSString *body = [NSString stringWithFormat:@"VocalReferences Apple store link: %@",kItunesLink];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:@"VocalReferences"];
        NSArray *toRecipients = [NSArray new];
        [picker setToRecipients:toRecipients];
        [picker setMessageBody:body isHTML:NO];
        [picker setSubject:@""];
        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!",nil) message:NSLocalizedString(@"Setup email in settings",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles: nil];
        [error show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)shareViaSMS{
    NSString *body = [NSString stringWithFormat:@"VocalReferences Apple store link: %@",kItunesLink];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = body;
        controller.recipients = nil;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_testimonials.count+_records.count > 0){
        [_emptyLabel setHidden:YES];
    } else {
        [_emptyLabel setHidden:NO];
    }
    return _testimonials.count+_records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AGRecordCell *cell = (AGRecordCell *)[tableView dequeueReusableCellWithIdentifier:@"recordCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    [cell stopUploadingAnimation];
    CGRect temp = cell.text.frame;
    temp.size.height = 22.f;
    cell.text.frame = temp;
    if(_testimonials.count >= indexPath.row+1){
        @try {
            [cell.favoriteIcon setHidden:YES];
            Testimonial *testimonial = _testimonials[indexPath.row];
            if(testimonial.type.integerValue == AudioTestimonial || testimonial.type.integerValue == VideoTestimonial){
                cell.text.text = testimonial.title;
            } else {
                cell.text.text = testimonial.title;
            }
            if(testimonial.image){
                cell.image.image = [UIImage imageWithData:testimonial.image];
            }
            
            CGRect temp = CGRectMake(100, 0, SCREEN_WIDTH-117, 20);
            [cell.text sizeToFit];
            if(cell.text.frame.size.height < temp.size.height){
                cell.text.frame = temp;
            } else if(cell.text.frame.size.height > 45){
                temp.size.height = 45;
                cell.text.frame = temp;
            } else {
                temp.origin.y = 3.f;
                temp.size.height = cell.text.frame.size.height;
                cell.text.frame = temp;
            }
            cell.date.text = [self stringFromDate:testimonial.date];
            
            cell.isLocal = YES;
            [cell.uploadIcon setImage:[[UIImage imageNamed:@"uploadIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            cell.uploadIcon.tintColor = [UIColor lightGrayColor];
            if([[AGUploadManager uploader] isUploadingNowTestimonial:testimonial]){
                [cell startUploadingAnimation];
            } else {
                [cell stopUploadingAnimation];
            }
            if(testimonial.type.integerValue == VideoTestimonial){
                [cell.playButton setImage:[UIImage imageNamed:@"playIconCell"] forState:UIControlStateNormal];
            } else {
                [cell.playButton setImage:nil forState:UIControlStateNormal];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception!: %@",exception);
        }
        @finally {
        }
    } else {
        @try {
            AGRecord *testimonial = _records[indexPath.row-_testimonials.count];
            
            [cell.favoriteIcon setHidden:!testimonial.isFavorite];
            
            if(testimonial.recordType == AudioTestimonial || testimonial.recordType == VideoTestimonial){
                cell.text.text = [testimonial.title stringByStrippingHTML];
            } else {
                cell.text.text = [testimonial.title stringByStrippingHTML];;
            }
            if(testimonial.picturePath.length > 20){
                [cell.image sd_setImageWithURL:[NSURL URLWithString:testimonial.picturePath]];
            } else {
                [cell.image sd_setImageWithURL:[NSURL URLWithString:testimonial.vssThumbnail]];
                if(testimonial.vssThumbnail.length < 20 && testimonial.recordType == AudioTestimonial){
                    cell.image.image = [UIImage imageNamed:@"audio_photo_centered"];
                }
            }
            
            CGRect temp = CGRectMake(100, 0, SCREEN_WIDTH-117, 20);
            [cell.text sizeToFit];
            if(cell.text.frame.size.height < temp.size.height){
                cell.text.frame = temp;
            } else if(cell.text.frame.size.height > 45){
                temp.size.height = 45;
                cell.text.frame = temp;
            }
            cell.date.text = [self convertDate:testimonial.updatedAt];//testimonial.createdAt;
            
            cell.isLocal = NO;
            [cell.uploadIcon setImage:[[UIImage imageNamed:@"uploadIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            cell.uploadIcon.tintColor = [UIColor colorWithRed:0.431 green:0.800 blue:0.271 alpha:1.000];
            
            switch (testimonial.status) {
                case 0:
                    
                    break;
                case 1:
                    break;
                case 2:{
                    NSURL *image = [[AGVssManager manager] previewUrlForVssId:testimonial.vssId];
                    if(image){
                        [cell.uploadIcon sd_setImageWithURL:image];
                    }
                    break;
                }
                case 3:{
                    [cell.uploadIcon setImage:[UIImage imageNamed:@"status_warn"]];
                    break;
                }
                default:
                    break;
            }
            if(testimonial.recordType == VideoTestimonial){
                [cell.playButton setImage:[UIImage imageNamed:@"playIconCell"] forState:UIControlStateNormal];
            } else {
                [cell.playButton setImage:nil forState:UIControlStateNormal];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception! %@",exception);
        }
        @finally {
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _tempIndexPath = indexPath;
    UIActionSheet *cellSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View",@"Edit",@"Favorite",@"Upload",@"Delete",@"Share",@"Email",@"SMS",@"Refresh", nil];
    cellSheet.tag = kCellSheet;
    [cellSheet showInView:self.view];
}

-(NSString *)convertDate:(NSString*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateU = [dateFormatter dateFromString:date];
    return [self stringFromDate:dateU];
}

-(NSString *)stringFromDate:(NSDate*)date{
    if(!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"dd-MMM-yy hh:mma"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _dateFormatter.locale = usLocale;
    }
    return [_dateFormatter stringFromDate:date];
}

#pragma mark - Bottom bar buttons actions

static NSString *const kRecordAudioViewController = @"recordAudioViewController";
static NSString *const kRecordVideoViewController = @"recordVideoViewController";
static NSString *const kRecordTextViewController = @"textRecordViewController";

- (IBAction)recordAudioPressed:(id)sender {
    if([self canAddRecord]){
        [self pushViewControllerWithName:kRecordAudioViewController];
    }
}

- (IBAction)recordVideoPressed:(id)sender {
    if([self canAddRecord]){
        [self showVideoRecorder];
    }
}

- (IBAction)recordTextPressed:(id)sender {
    if([self canAddRecord]){
        [self pushViewControllerWithName:kRecordTextViewController];
    }
}

-(void)pushViewControllerWithName:(NSString*)name{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:name];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Video recorder

-(void)showVideoRecorder{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,nil];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
    NSTimeInterval interval = 45.f;
    _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    _imagePicker.videoMaximumDuration = interval;
    _imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    NSURL *videoPath  = [info objectForKey:UIImagePickerControllerMediaURL];
    AGReferenceDetailsViewController *ref = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"referenceDetails"];
    ref.testimonialType = VideoTestimonial;
    ref.recordedVideo = videoPath;
    [self.navigationController pushViewController:ref animated:NO];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Upgrade alert

-(BOOL)canAddRecord{
    NSInteger limit = [AGThisUser currentUser].limitRecords.integerValue;
    if(limit > _records.count+_testimonials.count){
        return YES;
    } else {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Upgrade account" message:@"You have reached your limit of records. Please upgrade your account to add more testimonials." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Upgrade", nil];
        error.tag = 1234;
        [error show];
        return NO;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1234){
        if(buttonIndex == 1){
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"upgradeViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if(alertView.tag == kDeleteAlert){
        if(buttonIndex == 1){
            if(_testimonials.count >= _tempIndexPath.row+1){
                if([self canAddRecord]){
                    [HUD show:YES];
                    Testimonial *testimon = _testimonials[_tempIndexPath.row];
                    [testimon remove];
                    [self updateTable];
                }
            } else {
                if([self canAddRecord]){
                    [HUD show:YES];
                    AGRecord *record = _records[_tempIndexPath.row-_testimonials.count];
                    [record remove];
                }
            }
        }
    }
}
@end
