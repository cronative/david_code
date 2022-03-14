//
//  AGProfileViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 28.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGProfileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "AGStringPicker.h"

@interface AGProfileViewController ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, JXApiDelegate, AGStringPickerDelegate>{
    CGFloat keyboardHeight;
    CGRect _tempScrollFrame;
    MBProgressHUD *HUD;
    BOOL _videoChanged;
}

@property (nonatomic, strong) JXApiRequest *updateProfileApi;
@property (nonatomic, strong) JXApiRequest *updateVideo;

@property (weak, nonatomic) IBOutlet UIButton *recButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *companyName;
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *postal;
@property (weak, nonatomic) IBOutlet UITextField *contact;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *website;
@property (weak, nonatomic) IBOutlet UITextField *businessCategory;
@property (weak, nonatomic) IBOutlet UITextField *merchantEmail;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UIView *fieldsView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSURL *recordedVideo;

@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic, strong) AppDelegate *appDel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@end

@implementation AGProfileViewController



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    _appDel = [UIApplication sharedApplication].delegate;
    
    [self setFonts];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollTableToEnd:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTableToNormalSize:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterFullscreen)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exitFullscreen)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFulscreen)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preparedForPlay)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:nil];
    
    
    if([AGThisUser currentUser].googleCloudFileName.length > 20){
        _recordedVideo = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",GOOGLE_STORAGE,[AGThisUser currentUser].googleCloudFileName]];
    }
    [self fillFields];
    [self setupVideoPlayer];
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.bounds = [UIScreen mainScreen].bounds;
    [self setupScroll];
}
-(void)viewWillLayoutSubviews{
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.bounds = [UIScreen mainScreen].bounds;
}
-(void)setFonts{
    [_recButton applyAwesomeFontWithSize:18.f];
    [_saveButton applyAwesomeFontWithSize:24.f];
    [_playButton applyAwesomeFontWithSize:30.f];
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    
    [[_recButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_recButton setImage:[[UIImage imageNamed:@"recordVideo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_recButton setTintColor:[UIColor whiteColor]];
    
    [[_saveButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_saveButton setImage:[[UIImage imageNamed:@"disk@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_saveButton setTintColor:[UIColor whiteColor]];
}

-(void)fillFields{
    _companyName.text = [AGThisUser currentUser].companyName;
    _country.text = [AGThisUser currentUser].country;
    _state.text = [AGThisUser currentUser].state;
    _postal.text = [AGThisUser currentUser].postalCode;
    _contact.text = [AGThisUser currentUser].phoneNumber;
    _firstName.text = [AGThisUser currentUser].firstName;
    _lastName.text = [AGThisUser currentUser].lastName;
    _address.text = [AGThisUser currentUser].address;
    _city.text = [AGThisUser currentUser].city;
    _website.text = [AGThisUser currentUser].website;
    _businessCategory.text = GetCategoryByID([AGThisUser currentUser].businessCategory.integerValue);
    _merchantEmail.text = [AGThisUser currentUser].merchantEmail;
    
    if(!_recordedVideo){
        [_playButton setImage:[UIImage imageNamed:@"video_photo_centered-copy"] forState:UIControlStateNormal];
    } else {
        
        [_playButton setImage:[UIImage imageNamed:@"playIconCell"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setupVideoPlayer{
    _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:_recordedVideo];
    CGRect frame = _videoPlayerView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    _videoPlayer.view.frame = frame;
    [_videoPlayerView addSubview:_videoPlayer.view];
    _videoPlayer.controlStyle = MPMovieControlStyleNone;
    [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    [_videoPlayer prepareToPlay];
}

-(void)enterFullscreen{
    NSLog(@"Enter fullscreen");
    _videoPlayer.controlStyle = MPMovieControlStyleFullscreen;
    [_videoPlayer setScalingMode:MPMovieScalingModeNone];
    _appDel.fullScreenVideoIsPlaying = YES;
}

-(void)willExitFulscreen{
    NSLog(@"Will Exit fullscreen");
    _appDel.fullScreenVideoIsPlaying = NO;
}

-(void)exitFullscreen{
    NSLog(@"Exit fullscreen");
    _videoPlayer.controlStyle = MPMovieControlStyleNone;
    [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    _appDel.fullScreenVideoIsPlaying = NO;
}

-(void)setupScroll{
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH,_fieldsView.frame.origin.y+_fieldsView.frame.size.height+10);
    _tempScrollFrame = _scrollView.frame;
}

#pragma mark - TextFields

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if([textField isEqual:_businessCategory]){
        [self resignAllTextFields];
        [self showStringPicker];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
            [_country becomeFirstResponder];
            break;
        case 1:
            [_state becomeFirstResponder];
            break;
        case 2:
            [_postal becomeFirstResponder];
            break;
        case 3:
            [_contact becomeFirstResponder];
            break;
        case 4:
            [_firstName becomeFirstResponder];
            break;
        case 5:
            [_lastName becomeFirstResponder];
            break;
        case 6:
            [_address becomeFirstResponder];
            break;
        case 7:
            [_city becomeFirstResponder];
            break;
        case 8:
            [_website becomeFirstResponder];
            break;
        case 9:
            [self resignAllTextFields];
            [self showStringPicker];
            break;
        case 10:
            [_merchantEmail becomeFirstResponder];
            break;
        case 11:
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

-(void)showStringPicker{
    NSArray *items = @[@"Arts & Entertainment", @"Automotive", @"Business & Professional Services", @"Clothing & Accessories", @"Community & Government", @"Computers & Electronics", @"Construction & Contractors", @"Education", @"Food & Dining", @"Health & Medicine", @"Home & Garden", @"Industry & Agriculture", @"Media & Communications", @"Personal Care & Services", @"Real Estate", @"Shopping", @"Sports & Recreation", @"Travel & Transportation"];
    AGStringPicker *picker = [[AGStringPicker alloc] init];
    picker.delegate = self;
    [picker showPickerInView:self.view withItems:items];
}

-(void)doneWithString:(NSString *)string{
    _businessCategory.text = string;
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

#pragma mark - Video player

- (IBAction)recordVideo:(id)sender {
    [self showVideoRecorder];
}

- (IBAction)playVideo:(id)sender {
    if(!_recordedVideo) return;
    [_videoPlayer prepareToPlay];
    [_videoPlayer setFullscreen:YES animated:YES];
    [_videoPlayer play];
}

#pragma mark - Recorder

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
    [_playButton setImage:[UIImage imageNamed:@"playIconCell"] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^{
        _videoChanged = YES;
        _recordedVideo = [info objectForKey:UIImagePickerControllerMediaURL];
        [_videoPlayer setContentURL:_recordedVideo];
        [_videoPlayer prepareToPlay];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)preparedForPlay{
    [_videoPlayer pause];
}

#pragma mark - API

- (IBAction)savePressed:(id)sender {
    if(_videoChanged){
        [HUD show:YES];
        [self uploadVideo];
    } else {
        [self updateProfile];
    }
}

-(void)updateProfile{
    [HUD show:YES];
    _updateProfileApi = [JXApiRequest new];
    _updateProfileApi.delegate = self;
    NSString *methode = [NSString stringWithFormat:@"%@%@",UPDATE_PROFILE,[[AGThisUser currentUser] getUserAuthToken]];
    [_updateProfileApi requestWithDomain:APP_DOMAIN methode:methode parameters:[self parametersForUpdate] photoContent:nil videoContent:nil audioContent:nil];
}

-(NSDictionary *)parametersForUpdate{
    NSString *company = [NSString stringWithFormat:@"%@",_companyName.text];
    NSString *country = [NSString stringWithFormat:@"%@",_country.text];
    NSString *state = [NSString stringWithFormat:@"%@",_state.text];
    NSString *postal = [NSString stringWithFormat:@"%@",_postal.text];
    NSString *contact = [NSString stringWithFormat:@"%@",_contact.text];
    NSString *firstName = [NSString stringWithFormat:@"%@",_firstName.text];
    NSString *lastName = [NSString stringWithFormat:@"%@",_lastName.text];
    NSString *address = [NSString stringWithFormat:@"%@",_address.text];
    NSString *city = [NSString stringWithFormat:@"%@",_city.text];
    NSString *website = [NSString stringWithFormat:@"%@",_website.text];
    NSString *busCat = [NSString stringWithFormat:@"%d",GetIdByCategory(_businessCategory.text.UTF8String)];
    NSString *merchantEmail = [NSString stringWithFormat:@"%@",_merchantEmail.text];
    
    NSDictionary *params = @{kCompanyName:company, kCountry:country, kState:state, kPostalCode:postal, kPhoneNumber:contact, kFirstName:firstName, kLastName:lastName, kAddress:address, kCity:city, kWebsite:website, kBusinessCategoryId:busCat, kMerchantEmail: merchantEmail};
    return @{kJsonObjectKey:params.JSON};
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    if([request isEqual:_updateProfileApi]){
        [[AGThisUser currentUser] updateProfile];
        [HUD hide:YES afterDelay:1.f];
        NSLog(@"Finish updating! : %@",response);
    } else if([request isEqual:_updateVideo]){
        NSLog(@"Uploading video finish:%@",response);
        [self updateProfile];
    }
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    [HUD hide:YES];
    NSLog(@"Error: %@",connectionError.localizedDescription);
    if([request isEqual:_updateVideo]){
        [self updateProfile];
    }
}

#pragma mark - Upload video

-(void)uploadVideo{
    AGApi *getLink = [AGApi new];
    [getLink POSTrequestWith:GET_CLOUD_LINK parameters:nil success:^(id response, id wrongObject) {
        NSLog(@"Success CLOUD: %@",response);
        NSString *path = response[@"link"];
        [self uploadWithLink:path];
    } failure:^(NSError *error, NSString *errorString) {
        NSLog(@"Failure cloud: %@",error);
    }];
}

-(void)uploadWithLink:(NSString *)url{
    NSString *pth = [DOCUMENTS stringByAppendingPathComponent:@"video.mp4"];
    NSURL *mp4 = [NSURL fileURLWithPath:pth];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pth isDirectory:NO]){
        [[NSFileManager defaultManager] removeItemAtPath:pth error:nil];
    }
    [self convertVideoToLowQuailtyWithInputURL:_recordedVideo outputURL:mp4 handler:^(AVAssetExportSession *exportSession)
     {
         NSLog(@"Upload start!");
         __block NSString *filename;
         AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
         [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
             filename = [NSString stringWithFormat:@"%@.mp4",url.lastPathComponent];
             [formData appendPartWithFormData:[@"video" dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
             [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"filename"];
             [formData appendPartWithFileData:[NSData dataWithContentsOfURL:mp4] name:@"file" fileName:filename mimeType:@"video/mp4"];
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Success: %@", responseObject);
             [HUD hide:YES];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"operation: %@",operation.responseString);
             NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
             NSError *jsonError;
             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&jsonError];
             
             NSString *file = json[@"filePath"];
             file = [file lastPathComponent];
             NSLog(@"Filename: %@",file);
             NSString *resultURL = [NSString stringWithFormat:@"video/%@",file];
             [self saveVideoToProfileWithVideoLink:resultURL];
         }];
     }];
}

-(void)saveVideoToProfileWithVideoLink:(NSString *)cloudFile{
    _updateVideo = [JXApiRequest new];
    _updateVideo.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",CHANGE_USER_VIDEO,[[AGThisUser currentUser] getUserAuthToken]];
    NSDictionary *params = @{kJsonObjectKey:@{kGoogleCloudFileName:cloudFile}.JSON};
    [_updateVideo requestWithDomain:APP_DOMAIN methode:method parameters:params photoContent:nil videoContent:nil audioContent:nil];
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
        NSLog(@"video is portrait ");
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
