//
//  AGRecordVideoViewController.m
//  VocalReferences
//
//  Created by Andrey on 19.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGRecordVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AGReferenceDetailsViewController.h"

@interface AGRecordVideoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    int _seconds;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *content;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIProgressView *recordProgress;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation AGRecordVideoViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopVideo)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStateDidChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [self setUpViews];
    
    _content.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _content.layer.shadowOffset = CGSizeMake(2., 2.f);
    _content.layer.shadowOpacity = 0.3;
    _content.layer.shadowRadius = 2.f;
    [self initViewAndPlayer];
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    [_recordButton applyAwesomeFontWithSize:18.];
    [_playButton applyAwesomeFontWithSize:22.];
    [_doneButton applyAwesomeFontWithSize:18.];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setup views

-(void)setUpViews{
    _videoPlayerView.frame = CGRectMake(0, 0, _content.frame.size.width, _content.frame.size.width*250/450);
    CGRect contFrame = _content.frame;
    contFrame.size.height = _videoPlayerView.frame.size.height+40;
    _content.frame = contFrame;
}

#pragma mark - Video player

-(void)initViewAndPlayer{
    AVAsset *video = [AVAsset assetWithURL:_recordedVideo];
    if([self isVideoPortrait:video]){
        _content.frame = CGRectMake(10, 10, SCREEN_WIDTH-20, _scrollView.frame.size.height-20);
        _videoPlayerView.frame = CGRectMake(0, 0, _content.frame.size.width, _content.frame.size.height-40);
    }
    _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:_recordedVideo];
    CGRect frame = _videoPlayerView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    _videoPlayer.view.frame = frame;
    [_videoPlayerView addSubview:_videoPlayer.view];
    _videoPlayer.controlStyle = MPMovieControlStyleNone;
    [_videoPlayer prepareToPlay];
    [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
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

- (IBAction)playPausePressed:(UIButton *)sender {
    if(_videoPlayer.playbackState == MPMoviePlaybackStatePlaying){
        [_videoPlayer stop];
    } else {
        [_videoPlayer play];
    }
}

-(void)stopVideo{
    [_playButton setSelected:NO];
    [_timer invalidate];
    [_recordProgress setHidden:YES];
    [_timerLabel setHidden:YES];
}

-(void)playerStateDidChanged{
    if(_videoPlayer.playbackState == MPMoviePlaybackStatePlaying){
        [_playButton setSelected:YES];
        [_recordProgress setHidden:NO];
        [_timerLabel setHidden:NO];
        _seconds = 0;
        [_recordProgress setProgress:0];
        _timerLabel.text = @"0:00";
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playerTick) userInfo:nil repeats:YES];
    }
}

-(void)playerTick{
    _seconds ++;
    [_recordProgress setProgress:(float)_seconds/(float)(_videoPlayer.duration*10)];
    
    NSInteger sec = _seconds/10;
    if(sec < 10){
        _timerLabel.text = [NSString stringWithFormat:@"0:0%d",sec];
    } else {
        _timerLabel.text = [NSString stringWithFormat:@"0:%d",sec];
    }
}

#pragma mark - Video Recorder

- (IBAction)recordPressed:(id)sender {
    [self showVideoRecorder];
}

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
    _recordedVideo  = [info objectForKey:UIImagePickerControllerMediaURL];
    [_videoPlayer.view removeFromSuperview];
    [self initViewAndPlayer];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Done

- (IBAction)donePressed:(id)sender {
    AGReferenceDetailsViewController *ref = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"referenceDetails"];
    ref.testimonialType = VideoTestimonial;
    [self.navigationController pushViewController:ref animated:YES];
}

@end
