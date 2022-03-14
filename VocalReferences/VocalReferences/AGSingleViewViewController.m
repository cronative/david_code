//
//  AGSingleViewViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 05.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGSingleViewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AGUploadManager.h"
#import "AGEditViewController.h"

#define kOffsetX 10.f

@interface AGSingleViewViewController ()<AVAudioPlayerDelegate>{
    int _seconds;
    int _duration;
    int _currentDuration;
    BOOL _uploaded;
    BOOL _uploading;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (strong, nonatomic)  UIButton *playButton;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic)  UIProgressView *recordProgress;
@property (strong, nonatomic)  UILabel *timerLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) UIImageView *uploadIcon;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@end

@implementation AGSingleViewViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    switch (_testimonial.type.integerValue) {
        case TextTestimonial:
            [self createViewsForTextTestimonial];
            break;
        case AudioTestimonial:
            [self createViewsForAudioTestimonial];
            break;
        case VideoTestimonial:{
            NSString * filePath=[NSTemporaryDirectory() stringByAppendingPathComponent:@"vidos.mp4"];
            [_testimonial.data writeToFile:filePath atomically:YES];
            _videoUrl = [NSURL fileURLWithPath:filePath];
            [self createViewsForVideoTestimonial];
            break;
        }
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDidFinish) name:kObjectUploadedNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFonts{
    [_backButton applyAwesomeFontWithSize:18.f];
}

- (IBAction)backPressed:(id)sender {
    [_videoPlayer stop];
    [_audioPlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Text view

-(void)createViewsForTextTestimonial{
    CGFloat nextY = 10;
    if(_testimonial.image){
        CGRect imageFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, (SCREEN_WIDTH-20)*250/450);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setClipsToBounds:YES];
        [imageView setImage:[UIImage imageWithData:_testimonial.image]];
        [_scrollView addSubview:imageView];
        nextY = nextY+imageFrame.size.height;
    }
    CGRect contentFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, 600);
    UIView *contentView = [[UIView alloc] initWithFrame:contentFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:contentView];
    
    nextY = 5;
    CGFloat contentWidth = contentFrame.size.width-kOffsetX*2;
    
    //Title label
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    title.font = [UIFont fontWithName:kHelveticaNeueMedium size:16.];
    title.textColor = [UIColor darkGrayColor];
    title.text = _testimonial.title;
    [contentView addSubview:title];
    nextY = nextY + title.frame.size.height;
    //Text body
    UILabel *textBody = [[UILabel alloc] initWithFrame:CGRectMake(20, nextY, contentWidth-20, 100)];
    textBody.numberOfLines = 0;
    textBody.lineBreakMode = NSLineBreakByWordWrapping;
    textBody.text = _testimonial.text;
    textBody.font = [UIFont fontWithName:kHelveticaNeueRegular size:14.];
    textBody.textColor = [UIColor colorWithWhite:0.475 alpha:1.000];
    [textBody sizeToFit];
    [contentView addSubview:textBody];
    nextY = nextY+textBody.frame.size.height+30;
    //Keywords
    UILabel *tags = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    tags.numberOfLines = 0;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Tags: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:_testimonial.keywords attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [tags setAttributedText:str];
    [tags sizeToFit];
    [contentView addSubview:tags];
    nextY = nextY+tags.frame.size.height;
    
    //Uploaded
    UILabel *uploaded = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    str = [[NSMutableAttributedString alloc] initWithString:@"Uploaded: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:[self stringFromDate:_testimonial.date] attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [uploaded setAttributedText:str];
    [contentView addSubview:uploaded];
    nextY = nextY+uploaded.frame.size.height+5;
    
    contentFrame.size.height = nextY;
    contentView.frame = contentFrame;
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, nextY+10);
    
    [self addIconAndActivityToContentView:contentView];
}


#pragma mark - Audio view

-(void)createViewsForAudioTestimonial{
    CGFloat nextY = 10;
    CGRect imageFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, (SCREEN_WIDTH-20)*250/450);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [imageView setClipsToBounds:YES];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if(_testimonial.image){
        [imageView setImage:[UIImage imageWithData:_testimonial.image]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"audio_photo"]];
    }
    [_scrollView addSubview:imageView];
    nextY = nextY+imageFrame.size.height;
    CGRect contentFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, 600);
    UIView *contentView = [[UIView alloc] initWithFrame:contentFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:contentView];
    
    nextY = 5;
    CGFloat contentWidth = contentFrame.size.width-kOffsetX*2;

    //Timer
    _timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, imageFrame.size.height-60, 60, 21)];
    _timerLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:15.f];
    _timerLabel.shadowColor = [UIColor darkGrayColor];
    _timerLabel.shadowOffset = CGSizeMake(1., 1.);
    _timerLabel.text = @"0:00";
    _timerLabel.textColor = [UIColor whiteColor];
    [_scrollView addSubview:_timerLabel];
    
    //PlayerView
    UIView *playerView = [[UIView alloc] initWithFrame:CGRectMake(10, imageFrame.size.height-31, SCREEN_WIDTH-20, 41.f)];
    playerView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.800];
    [_scrollView addSubview:playerView];
    //PlayButton
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(playerView.frame.size.width/2-20, 1, 40, 40);
    [_playButton setTitle:@"" forState:UIControlStateNormal];
    [_playButton setTitle:@"" forState:UIControlStateSelected];
    [_playButton applyAwesomeFontWithSize:22.f];
    [_playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playPressed:) forControlEvents:UIControlEventTouchUpInside];
    [playerView addSubview:_playButton];
    
    //Progress
    _recordProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_recordProgress setProgressTintColor:[UIColor colorWithRed:0.898 green:0.161 blue:0.161 alpha:1.000]];
    [_recordProgress setTrackTintColor:[UIColor colorWithRed:0.733 green:0.737 blue:0.737 alpha:1.000]];
    _recordProgress.frame = CGRectMake(0, 0, SCREEN_WIDTH-20, 1);
    [_recordProgress setProgress:0.0];
    [playerView addSubview:_recordProgress];
    [self stop];
    //
    
    //Title label
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    title.font = [UIFont fontWithName:kHelveticaNeueMedium size:16.];
    title.textColor = [UIColor darkGrayColor];
    title.text = _testimonial.title;
    [contentView addSubview:title];
    nextY = nextY + title.frame.size.height+10;
    
    //Text body
    UILabel *textBody = [[UILabel alloc] initWithFrame:CGRectMake(20, nextY, contentWidth-20, 100)];
    textBody.numberOfLines = 0;
    textBody.lineBreakMode = NSLineBreakByWordWrapping;
    textBody.text = _testimonial.descript;
    textBody.font = [UIFont fontWithName:kHelveticaNeueRegular size:14.];
    textBody.textColor = [UIColor colorWithWhite:0.475 alpha:1.000];
    [textBody sizeToFit];
    [contentView addSubview:textBody];
    nextY = nextY+textBody.frame.size.height+30;
    
    //Keywords
    UILabel *tags = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    tags.numberOfLines = 0;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Tags: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:_testimonial.keywords attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [tags setAttributedText:str];
    [tags sizeToFit];
    [contentView addSubview:tags];
    nextY = nextY+tags.frame.size.height;
    
    //Uploaded
    UILabel *uploaded = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    str = [[NSMutableAttributedString alloc] initWithString:@"Uploaded: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:[self stringFromDate:_testimonial.date] attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [uploaded setAttributedText:str];
    [contentView addSubview:uploaded];
    nextY = nextY+uploaded.frame.size.height+5;
    
    contentFrame.size.height = nextY;
    contentView.frame = contentFrame;
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, nextY+10);
    
    [self addIconAndActivityToContentView:contentView];
}

#pragma mark - Audio player

- (void)playPressed:(UIButton*)sender {
    [sender setSelected:!sender.isSelected];
    if(sender.isSelected){
        [self play];
    } else {
        [self stop];
    }
}

-(void)play{
    if([_audioPlayer isPlaying]){
        [_audioPlayer stop];
    }
    NSError *playerError;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithData:_testimonial.data] error:&playerError];

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

#pragma mark - Video View

-(void)createViewsForVideoTestimonial{
    CGFloat nextY = 10;
    CGRect imageFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, (SCREEN_WIDTH-20)*250/450);
    UIView *videoPlayer = [[UIView alloc] initWithFrame:imageFrame];
    videoPlayer.backgroundColor = [UIColor blackColor];
    [_scrollView addSubview:videoPlayer];
    nextY = nextY+imageFrame.size.height;
    
    CGRect contentFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, 600);
    UIView *contentView = [[UIView alloc] initWithFrame:contentFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:contentView];
    
    nextY = 5;
    CGFloat contentWidth = contentFrame.size.width-kOffsetX;
    
    _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:_videoUrl];
    CGRect frame = videoPlayer.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    _videoPlayer.view.frame = frame;
    [videoPlayer addSubview:_videoPlayer.view];
    _videoPlayer.controlStyle = MPMovieControlStyleEmbedded;
    [_videoPlayer prepareToPlay];
    //[_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    
    //Title label
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    title.font = [UIFont fontWithName:kHelveticaNeueMedium size:16.];
    title.textColor = [UIColor darkGrayColor];
    title.text = _testimonial.title;
    [contentView addSubview:title];
    nextY = nextY + title.frame.size.height+10;
    
    //Text body
    UILabel *textBody = [[UILabel alloc] initWithFrame:CGRectMake(20, nextY, contentWidth-20, 100)];
    textBody.numberOfLines = 0;
    textBody.lineBreakMode = NSLineBreakByWordWrapping;
    textBody.text = _testimonial.descript;
    textBody.font = [UIFont fontWithName:kHelveticaNeueRegular size:14.];
    textBody.textColor = [UIColor colorWithWhite:0.475 alpha:1.000];
    [textBody sizeToFit];
    [contentView addSubview:textBody];
    nextY = nextY+textBody.frame.size.height+30;
    
    //Keywords
    UILabel *tags = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    tags.numberOfLines = 0;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Tags: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:_testimonial.keywords attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [tags setAttributedText:str];
    [tags sizeToFit];
    [contentView addSubview:tags];
    nextY = nextY+tags.frame.size.height;
    
    //Uploaded
    UILabel *uploaded = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    str = [[NSMutableAttributedString alloc] initWithString:@"Uploaded: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:[self stringFromDate:_testimonial.date] attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [uploaded setAttributedText:str];
    [contentView addSubview:uploaded];
    nextY = nextY+uploaded.frame.size.height+5;
    
    contentFrame.size.height = nextY;
    contentView.frame = contentFrame;
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, nextY+10);
    
    [self addIconAndActivityToContentView:contentView];
}

-(void)addIconAndActivityToContentView:(UIView *)contentView{
    CGRect iconFrame = CGRectMake(SCREEN_WIDTH-40-kOffsetX, contentView.frame.size.height-30, 20, 20);
    _uploadIcon = [[UIImageView alloc] initWithFrame:iconFrame];
    _uploadIcon.image = [[UIImage imageNamed:@"uploadIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_uploadIcon setTintColor:[UIColor lightGrayColor]];
    [contentView addSubview:_uploadIcon];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [contentView addSubview:_activityIndicator];
    _activityIndicator.frame = iconFrame;
    [_activityIndicator setHidesWhenStopped:YES];
    if([[AGUploadManager uploader] isUploadingNowTestimonial:_testimonial]){
        [self startActivity];
    } else {
        [self stopActivity];
    }
    _uploaded = NO;
}

-(void)startActivity{
    [_activityIndicator startAnimating];
    [_uploadIcon setHidden:YES];
    [_editButton setHidden:YES];
    [_uploadButton setHidden:YES];
    _uploading = YES;
}
-(void)stopActivity{
    [_activityIndicator stopAnimating];
    [_uploadIcon setHidden:NO];
    _uploading = NO;
}

#pragma mark - Actions

- (IBAction)editPressed:(id)sender {
    if(_uploading){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uploading.." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    } else {
        AGEditViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"editViewController"];
        vc.testimonial = _testimonial;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)uploadPressed:(id)sender {
    if(_uploaded || _uploading) return;
    [self startActivity];
    [[AGUploadManager uploader] uploadTestimonials:@[_testimonial]];
}

-(void)uploadDidFinish{
    _uploaded = YES;
    [self stopActivity];
    [_uploadIcon setTintColor:[UIColor colorWithRed:0.431 green:0.800 blue:0.271 alpha:1.000]];
}
@end
