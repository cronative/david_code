//
//  AGReferenceDetailsViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 23.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGReferenceDetailsViewController.h"
#import "Testimonial.h"
#import <AVFoundation/AVFoundation.h>

@interface AGReferenceDetailsViewController ()<UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate>{
    CGFloat keyboardHeight;
    CGRect _tempScrollFrame;
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *saveAsdefaultButton;

@property (weak, nonatomic) IBOutlet UITextField *testimonialTitle;
@property (weak, nonatomic) IBOutlet UITextField *companyName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *website;
@property (weak, nonatomic) IBOutlet UITextField *keywords;
@property (weak, nonatomic) IBOutlet UITextField *descript;
@property (weak, nonatomic) IBOutlet UITextField *customer;
@property (weak, nonatomic) IBOutlet UITextField *customerEmail;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *customerView;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@end

@implementation AGReferenceDetailsViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    [self loadDefaults];
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupScroll];
    
}

-(void)viewWillLayoutSubviews{
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.bounds = [UIScreen mainScreen].bounds;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollTableToEnd:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTableToNormalSize:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self setupScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    [_doneButton applyAwesomeFontWithSize:26.];
    [[_doneButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_doneButton setImage:[[UIImage imageNamed:@"Circular-tick-done@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_doneButton setTintColor:[UIColor whiteColor]];
    
    switch (_testimonialType) {
        case AudioTestimonial:
            _testimonialTitle.text = @"Audio Testimonial";
            break;
        case TextTestimonial:
            _testimonialTitle.text = @"Text Testimonial";
            break;
        case VideoTestimonial:
            _testimonialTitle.text = @"Video Testimonial";
            break;
        default:
            break;
    }
    
    _titleView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.shadowOffset = CGSizeMake(0., 1.f);
    _titleView.layer.shadowOpacity = 1.;
    _titleView.layer.shadowRadius = 1.f;
    
    _infoView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _infoView.layer.shadowOffset = CGSizeMake(0., 1.f);
    _infoView.layer.shadowOpacity = 1.;
    _infoView.layer.shadowRadius = 1.f;
    
    _customerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _customerView.layer.shadowOffset = CGSizeMake(0., 1.f);
    _customerView.layer.shadowOpacity = 1.;
    _customerView.layer.shadowRadius = 1.f;
}

-(void)setupScroll{
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _doneButton.frame.origin.y+_doneButton.frame.size.height+10);
    NSLog(@"SCROLL CONTENT SIZE: %@",NSStringFromCGSize(_scrollView.contentSize));
    NSLog(@"SCROLL RECT: %@",NSStringFromCGRect(_scrollView.frame));
    CGRect tempFrame = _scrollView.frame;
    tempFrame.size.height = SCREEN_HEIGHT-64;
    _scrollView.frame = tempFrame;
    _tempScrollFrame = _scrollView.frame;
}

- (IBAction)backpressed:(id)sender {
    UIAlertView *save = [[UIAlertView alloc] initWithTitle:@"Save changes?" message:@"Save changes before exit?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    save.tag = 123;
    [save show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 123){
        if(buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self saveTestimonialToDB];
        }
    }
}

#pragma mark - Default info

-(void)loadDefaults{
    AGDefaultInfo *def = [[AGDefaultInfo alloc] init];
    _companyName.text = def.companyName;
    _phoneNumber.text = def.phoneNumber;
    _website.text = def.website;
    _keywords.text = def.keywords;
    _descript.text = def.descript;
}

- (IBAction)saveAsDefaultPressed:(id)sender {
    AGDefaultInfo *def = [[AGDefaultInfo alloc] init];
    def.companyName = _companyName.text;
    def.phoneNumber = _phoneNumber.text;
    def.website = _website.text;
    def.keywords = _keywords.text;
    def.descript = _descript.text;
    [def save];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - TextFields

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
            [_companyName becomeFirstResponder];
            break;
        case 1:
            [_phoneNumber becomeFirstResponder];
            break;
        case 2:
            [_website becomeFirstResponder];
            break;
        case 3:
            [_keywords becomeFirstResponder];
            break;
        case 4:
            [_descript becomeFirstResponder];
            break;
        case 5:
            [_customer becomeFirstResponder];
            break;
        case 6:
            [_customerEmail becomeFirstResponder];
            break;
        case 7:
            [textField resignFirstResponder];
            break;
        default:
            break;
    }
    return YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self resignAllTextFields];
}

-(void)resignAllTextFields{
    for(UITextField *field in _textFields){
        [field resignFirstResponder];
    }
}

#pragma mark - Scroll size

-(void)scrollTableToEnd:(NSNotification*)aNotification{
    NSDictionary *keyboardAnimationDetail = [aNotification userInfo];
    NSValue* keyboardFrameBegin = [keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    NSLog(@"Rect %@",NSStringFromCGRect(keyboardFrameBeginRect));
    keyboardHeight = keyboardFrameBeginRect.size.height;
    CGRect tableFrame = CGRectMake(0, _tempScrollFrame.origin.y, _tempScrollFrame.size.width, _tempScrollFrame.size.height-keyboardFrameBeginRect.size.height);
    _scrollView.frame = tableFrame;
}

-(void)setTableToNormalSize:(NSNotification*)aNotification{
    NSLog(@"Keyboard hide!");
    _scrollView.frame = _tempScrollFrame;
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark - Core data

- (IBAction)savePressed:(id)sender {
    [self saveTestimonialToDB];
}

-(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)saveTestimonialToDB{
    [HUD show:YES];
    Testimonial *testimonialObject = [NSEntityDescription insertNewObjectForEntityForName:@"Testimonial"inManagedObjectContext:self.managedObjectContext];
    testimonialObject.userEmail = [[AGThisUser currentUser] userEmail];
    testimonialObject.date = [NSDate date];
    testimonialObject.type = [NSNumber numberWithInt:_testimonialType];
    testimonialObject.text = _text;
    testimonialObject.title = _testimonialTitle.text;
    testimonialObject.companyName = _companyName.text;
    testimonialObject.phoneNumber = _phoneNumber.text;
    testimonialObject.website = _website.text;
    testimonialObject.keywords = _keywords.text;
    testimonialObject.descript = _descript.text;
    testimonialObject.customer = _customer.text;
    testimonialObject.customerEmail = _customerEmail.text;
    switch (_testimonialType) {
        case AudioTestimonial:{
            testimonialObject.image = _image;
            testimonialObject.data = _recordedAudio;
            NSError *error;
            if (![self.managedObjectContext save:&error])
            {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            } else {
                NSLog(@"Testimonial saved in DB!");
                [[NSNotificationCenter defaultCenter] postNotificationName:kPopToMain object:nil];
            }
            break;
        }
        case VideoTestimonial:{
            NSString *pth = [DOCUMENTS stringByAppendingPathComponent:@"video.mp4"];
            NSURL *mp4 = [NSURL fileURLWithPath:pth];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:pth isDirectory:NO]){
                [[NSFileManager defaultManager] removeItemAtPath:pth error:nil];
            }
            [self convertVideoToLowQuailtyWithInputURL:_recordedVideo outputURL:mp4 handler:^(AVAssetExportSession *exportSession)
             {
                 if (exportSession.status == AVAssetExportSessionStatusCompleted){
                     testimonialObject.data = [NSData dataWithContentsOfURL:mp4];
                     testimonialObject.image = UIImageJPEGRepresentation([self createFrameFromVideo:_recordedVideo], 1.);
                     NSError *error;
                     if (![self.managedObjectContext save:&error])
                     {
                         NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [HUD hide:YES];
                             [[NSNotificationCenter defaultCenter] postNotificationName:kPopToMain object:nil];
                         });
                     } else {
                         NSLog(@"Testimonial saved in DB!");
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [HUD hide:YES];
                             [[NSNotificationCenter defaultCenter] postNotificationName:kPopToMain object:nil];
                         });
                     }
                 } else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [HUD hide:YES];
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Error video converting!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                         [alert show];
                     });
                 }
             }];
            break;
        }
        case TextTestimonial:{
            testimonialObject.image = _image;
            NSError *error;
            if (![self.managedObjectContext save:&error])
            {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            } else {
                NSLog(@"Testimonial saved in DB!");
                [[NSNotificationCenter defaultCenter] postNotificationName:kPopToMain object:nil];
            }            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Video convertor

-(UIImage *)createFrameFromVideo:(NSURL*)reaction{
    AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:reaction options:nil];
    UIImageOrientation thumbOrientation;
    AVAssetTrack *videoTrack = [[myAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    CGAffineTransform txf       = [videoTrack preferredTransform];
    if (txf.a == 0 && txf.b == 1.0 && txf.c == -1.0 && txf.d == 0) {
        thumbOrientation = UIImageOrientationRight;
    }
    if (txf.a == 0 && txf.b == -1.0 && txf.c == 1.0 && txf.d == 0) {
        thumbOrientation =  UIImageOrientationLeft;
    }
    if (txf.a == 1.0 && txf.b == 0 && txf.c == 0 && txf.d == 1.0) {
        thumbOrientation =  UIImageOrientationUp;
    }
    if (txf.a == -1.0 && txf.b == 0 && txf.c == 0 && txf.d == -1.0) {
        thumbOrientation = UIImageOrientationDown;
    }
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    imageGenerator.maximumSize = CGSizeMake(640, 1136);
    NSError *error;
    CMTime actualTime;
    CMTime temp = CMTimeMakeWithSeconds(1, 1);
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:temp actualTime:&actualTime error:&error];
    if (halfWayImage != NULL) {
        UIImage *tempReactionFrame = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:thumbOrientation];
        CGImageRelease(halfWayImage);
        return tempReactionFrame;
    } else {
        return nil;
    }
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.videoComposition = [self getVideoComposition:asset];
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

-(AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    if(isPortrait_) {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}

-(BOOL) isVideoPortrait:(AVAsset *)asset
{
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];

        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = FALSE;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = FALSE;
        }
    }
    return isPortrait;
}
@end
