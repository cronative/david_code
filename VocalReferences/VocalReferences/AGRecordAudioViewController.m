//
//  AGRecordAudioViewController.m
//  VocalReferences
//
//  Created by Andrey on 19.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGRecordAudioViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AGReferenceDetailsViewController.h"

static NSInteger const kChooseFromActionSheet = 12;

@interface AGRecordAudioViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,AVAudioPlayerDelegate>{
    int _seconds;
    int _duration;
    int _currentDuration;
    BOOL _imageAdded;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *content;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSURL *recordedFile;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIProgressView *recordProgress;
@property (weak, nonatomic) IBOutlet UIButton *hiddenButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@end

@implementation AGRecordAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    [self setUpViews];
    [self initSession];
    
    _content.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _content.layer.shadowOffset = CGSizeMake(2., 2.f);
    _content.layer.shadowOpacity = 0.3;
    _content.layer.shadowRadius = 2.f;
    _imageAdded = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    [_recordButton applyAwesomeFontWithSize:18.];
    [_playButton applyAwesomeFontWithSize:22.];
    [_doneButton applyAwesomeFontWithSize:18.];
    
    [[_recordButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_recordButton setImage:[[UIImage imageNamed:@"recordButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_recordButton setTintColor:[UIColor blackColor]];
    
    [[_doneButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_doneButton setImage:[[UIImage imageNamed:@"Circular-tick-done@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_doneButton setTintColor:[UIColor colorWithRed:0.600 green:0.800 blue:0.000 alpha:1.000]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setup views

-(void)setUpViews{
    _imageView.frame = CGRectMake(0, 0, _content.frame.size.width, (_content.frame.size.width*250/450)+40);
    _hiddenButton.frame = CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height-40);
    NSLog(@"Image frame = %@\nButton frame = %@",NSStringFromCGRect(_imageView.frame),NSStringFromCGRect(_hiddenButton.frame));
    CGRect contFrame = _content.frame;
    contFrame.size.height = _imageView.frame.size.height;
    _content.frame = contFrame;
}

#pragma mark - Add image

- (IBAction)addImagePressed:(id)sender {
    UIActionSheet *chooser = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Camera Roll", nil];
    chooser.tag = kChooseFromActionSheet;
    [chooser showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == kChooseFromActionSheet){
        switch (buttonIndex) {
            case 0:
                [self takePhotoFromCamera];
                break;
            case 1:
                [self takePhotoFromCameraRoll];
                break;
            default:
                break;
        }
    }
}

-(void)takePhotoFromCamera{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [imagePicker prefersStatusBarHidden];
    [imagePicker setNeedsStatusBarAppearanceUpdate];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

-(void)takePhotoFromCameraRoll{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _imageAdded = YES;
    [_imageView setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Recorder

- (IBAction)recordStartStop:(UIButton *)sender {
    if([sender isSelected]){
        if(_seconds < 10) return; //Return if recorded less then 1 sec.
    }
    
    [sender setSelected:!sender.isSelected];
    if([sender isSelected]){
        [_recordButton setTintColor:[UIColor colorWithRed:1.000 green:0.267 blue:0.267 alpha:1.000]];
        [self startRecording];
    } else {
        [_recordButton setTintColor:[UIColor blackColor]];
        CGRect playRect = _playButton.frame;
        playRect.origin.x = _content.frame.size.width-_doneButton.frame.origin.x-8-_doneButton.frame.size.width;
        _recordButton.frame = playRect;
        [_playButton setHidden:NO];
        [_doneButton setHidden:NO];
        [self stopRecording];
    }
}

-(void)startRecording{
    [_timerLabel setHidden:NO];
    [_recordProgress setHidden:NO];
    _timerLabel.text = @"0:00";
    [_playButton setEnabled:NO];
    _seconds = 0;
    [_recordProgress setProgress:0];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(tick) userInfo:nil repeats:YES];
    _recorder = [[AVAudioRecorder alloc] initWithURL:_recordedFile settings:nil error:nil];
    [_recorder prepareToRecord];
    [_recorder record];
}

-(void)initSession{
    _recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:_recordedFile settings:nil error:nil];
    [_recorder prepareToRecord];
}

-(void)tick{
    if(_seconds == 450){
        [self stopRecording];
    }
    _seconds ++;
    [_recordProgress setProgress:(float)_seconds/450.f];
    NSInteger sec = _seconds/10;
    if(sec < 10){
        _timerLabel.text = [NSString stringWithFormat:@"0:0%d",sec];
    } else {
        _timerLabel.text = [NSString stringWithFormat:@"0:%d",sec];
    }
}

-(void)stopRecording{
    [_timer invalidate];
    [_recorder stop];
    [_recordButton setSelected:NO];
    [_playButton setEnabled:YES];
    [_timerLabel setHidden:YES];
    [_recordProgress setHidden:YES];
}


#pragma mark - Audio player

- (IBAction)playPressed:(UIButton*)sender {
    [sender setSelected:!sender.isSelected];
    if(sender.isSelected){
        [self play];
    } else {
        [self stop];
    }
}

-(void)play{
    [_recordButton setEnabled:NO];
    if([_audioPlayer isPlaying]){
        [_audioPlayer stop];
    }
    NSError *playerError;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordedFile error:&playerError];
    if (_audioPlayer == nil)
    {
        NSLog(@"Error: %@",playerError.localizedDescription);
        return;
    }
    _timerLabel.text = @"0:00";
    _duration = (int)_audioPlayer.duration * 10;
    _currentDuration = 0;
    [_recordProgress setProgress:0];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(playerTick) userInfo:nil repeats:YES];
    [_timerLabel setHidden:NO];
    [_recordProgress setHidden:NO];
    
    _audioPlayer.delegate = self;
    [_audioPlayer play];
}

-(void)stop{
    [_timer invalidate];
    [_recordButton setEnabled:YES];
    [_audioPlayer stop];
    [_playButton setSelected:NO];
    [_timerLabel setHidden:YES];
    [_recordProgress setHidden:YES];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stop];
}

-(void)playerTick{
    if(_currentDuration == _duration){
        [self stop];
    }
    _currentDuration ++;
    [UIView animateWithDuration:0.1 animations:^{
        [_recordProgress setProgress:(float)_currentDuration/(float)_duration];
    }];
    
    NSInteger sec = _currentDuration/10;
    if(sec < 10){
        _timerLabel.text = [NSString stringWithFormat:@"0:0%d",sec];
    } else {
        _timerLabel.text = [NSString stringWithFormat:@"0:%d",sec];
    }
}

#pragma mark - Done

- (IBAction)donePressed:(id)sender {
    NSData *recordedAudio = [NSData dataWithContentsOfURL:_recordedFile];
    if(!recordedAudio) return;
    AGReferenceDetailsViewController *ref = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"referenceDetails"];
    ref.testimonialType = AudioTestimonial;
    if(_imageView.image){
        if(_imageAdded){
            ref.image = UIImageJPEGRepresentation(_imageView.image, 1.);
        } else {
            ref.image = UIImageJPEGRepresentation([UIImage imageNamed:@"audio_photo_centered"], 1.);
        }
    }
    ref.recordedAudio = recordedAudio;
    [self.navigationController pushViewController:ref animated:YES];
}
@end
