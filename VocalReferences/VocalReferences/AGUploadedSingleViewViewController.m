//
//  AGUploadedSingleViewViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 06.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGUploadedSingleViewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "AGEditViewController.h"

#define kOffsetX 10.f

@interface AGUploadedSingleViewViewController ()<AVAudioPlayerDelegate, UIWebViewDelegate, UIActionSheetDelegate, JXApiDelegate>{
    int _seconds;
    int _duration;
    int _currentDuration;
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic)  UIButton *playButton;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic)  UIProgressView *recordProgress;
@property (strong, nonatomic)  UILabel *timerLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *uploadIcon;
@property (nonatomic, strong) UIImageView *starIcon;
@property (nonatomic, strong) UILabel *views;

@end

@implementation AGUploadedSingleViewViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    [self setFonts];
    switch (_testimonial.recordType) {
        case TextTestimonial:
            [self createViewsForTextTestimonial];
            break;
        case AudioTestimonial:
            [self createViewsForAudioTestimonial];
            break;
        case VideoTestimonial:{
            [self createViewsForVideoTestimonial];
            break;
        }
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent) name:kNeedToUpdateListOfRecords object:nil];
    
    [self getViewsCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setFonts{
    [_backButton applyAwesomeFontWithSize:18.];
}

- (IBAction)backPressed:(id)sender {
    [_audioPlayer stop];
    [_videoPlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Text view

-(void)createViewsForTextTestimonial{
    CGFloat nextY = 10;
    if(_testimonial.picturePath.length > 20){
        CGRect imageFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, (SCREEN_WIDTH-20)*250/450);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setClipsToBounds:YES];
        [imageView sd_setImageWithURL:[NSURL URLWithString:_testimonial.picturePath]];
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
    textBody.text = _testimonial.textBody;
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
    str2 = [[NSMutableAttributedString alloc] initWithString:[self convertDate:_testimonial.updatedAt] attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
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
    if(_testimonial.picturePath.length > 20){
        [imageView sd_setImageWithURL:[NSURL URLWithString:_testimonial.picturePath]];
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
    
    if(_testimonial.url.length > 20){
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH)*250/450)];
        [_scrollView addSubview:webView];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_testimonial.url]];
        [webView loadRequest:req];
    } else {
    
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
    }
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
    nextY = nextY+tags.frame.size.height+10;
    
    //URL
    UIButton *url = [UIButton buttonWithType:UIButtonTypeSystem];
    url.frame = CGRectMake(kOffsetX, nextY, contentWidth, 25);
    str = [[NSMutableAttributedString alloc] initWithString:@"Url: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:_testimonial.url attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithRed:0.200 green:0.710 blue:0.898 alpha:1.000], NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]}];
    [str appendAttributedString:str2];
    [url setAttributedTitle:str forState:UIControlStateNormal];
    [contentView addSubview:url];
    [url addTarget:self action:@selector(openUrl) forControlEvents:UIControlEventTouchUpInside];
    nextY = nextY+url.frame.size.height+5;
    [url setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    //Views
    _views = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    str = [[NSMutableAttributedString alloc] initWithString:@"Views: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:_testimonial.countViews attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [_views setAttributedText:str];
    [contentView addSubview:_views];
    nextY = nextY+_views.frame.size.height+5;
    
    //Uploaded
    UILabel *uploaded = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    str = [[NSMutableAttributedString alloc] initWithString:@"Uploaded: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:[self convertDate:_testimonial.updatedAt] attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
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

static NSData *audio = nil;

-(void)play{
    if(!audio){
        [HUD show:YES];
        NSString *audioUrl = [NSString stringWithFormat:@"%@%@",GOOGLE_STORAGE,_testimonial.googleCloudLink];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            audio = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [self audioPrepared];
            });
        });
        
    } else {
        [self audioPrepared];
    }
    
}

-(void)audioPrepared{
    if([_audioPlayer isPlaying]){
        [_audioPlayer stop];
    }
    NSError *playerError;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:audio error:&playerError];
    
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
    
    
    if(_testimonial.url.length > 20){
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH)*250/450)];
        videoPlayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH)*250/450);
        [webView setScalesPageToFit:NO];
        [videoPlayer addSubview:webView];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_testimonial.url]];
        [webView loadRequest:req];
    } else {
        NSString *videoUrl = [NSString stringWithFormat:@"%@%@",GOOGLE_STORAGE,_testimonial.googleCloudLink];
        _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoUrl]];
        CGRect frame = videoPlayer.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        _videoPlayer.view.frame = frame;
        [videoPlayer addSubview:_videoPlayer.view];
        _videoPlayer.controlStyle = MPMovieControlStyleEmbedded;
        [_videoPlayer prepareToPlay];
    }
    
    nextY = videoPlayer.frame.size.height;
    
    CGRect contentFrame = CGRectMake(10, nextY, SCREEN_WIDTH-20, 600);
    UIView *contentView = [[UIView alloc] initWithFrame:contentFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:contentView];
    
    nextY = 5;
    CGFloat contentWidth = contentFrame.size.width-kOffsetX*2;
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
    nextY = nextY+tags.frame.size.height+10;
    
    //URL
    UIButton *url = [UIButton buttonWithType:UIButtonTypeSystem];
    url.frame = CGRectMake(kOffsetX, nextY, contentWidth, 25);
    str = [[NSMutableAttributedString alloc] initWithString:@"Url: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:_testimonial.url attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithRed:0.200 green:0.710 blue:0.898 alpha:1.000], NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]}];
    [str appendAttributedString:str2];
    [url setAttributedTitle:str forState:UIControlStateNormal];
    [contentView addSubview:url];
    [url addTarget:self action:@selector(openUrl) forControlEvents:UIControlEventTouchUpInside];
    nextY = nextY+url.frame.size.height+5;
    [url setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    //Views
    _views = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    str = [[NSMutableAttributedString alloc] initWithString:@"Views: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:_testimonial.countViews attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
    [str appendAttributedString:str2];
    [_views setAttributedText:str];
    [contentView addSubview:_views];
    nextY = nextY+_views.frame.size.height+5;
    
    //Uploaded
    UILabel *uploaded = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX, nextY, contentWidth, 25)];
    str = [[NSMutableAttributedString alloc] initWithString:@"Uploaded: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    str2 = [[NSMutableAttributedString alloc] initWithString:[self convertDate:_testimonial.updatedAt] attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:13.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
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
    [_uploadIcon setTintColor:[UIColor colorWithRed:0.431 green:0.800 blue:0.271 alpha:1.000]];
    [contentView addSubview:_uploadIcon];
    
    switch (_testimonial.status) {
        case 0:
            
            break;
        case 1:
            break;
        case 2:{
            NSURL *image = [[AGVssManager manager] previewUrlForVssId:_testimonial.vssId];
            if(image){
                [_uploadIcon sd_setImageWithURL:image];
            }
            break;
        }
        case 3:{
            [_uploadIcon setImage:[UIImage imageNamed:@"status_warn"]];
            break;
        }
        default:
            break;
    }
    
    _starIcon = [[UIImageView alloc] initWithFrame:CGRectMake(iconFrame.origin.x-30, iconFrame.origin.y, iconFrame.size.width, iconFrame.size.height)];
    [_starIcon setImage:[UIImage imageNamed:@"favoriteIcon"]];
    [_starIcon setHidden:!_testimonial.isFavorite];
    [contentView addSubview:_starIcon];
}

-(NSString *)convertDate:(NSString*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateU = [dateFormatter dateFromString:date];
    return [self stringFromDate:dateU];
}

-(NSString *)stringFromDate:(NSDate*)date{
    if(!date){
        return [self convertDate:_testimonial.createdAt];
    }
    NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"dd-MMM-yy hh:mma"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    _dateFormatter.locale = usLocale;
    return [_dateFormatter stringFromDate:date];
}

#pragma mark - Actions
-(void)updateContent{
    [HUD hide:YES];
    [_starIcon setHidden:!_testimonial.isFavorite];
}

- (IBAction)sharePressed:(id)sender {
    //[_testimonial shareInViewController:self];
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"SMS",@"Facebook",@"Google+",@"LinkedIn",@"Twitter", nil];
    [menu showInView:self.view];
}

- (IBAction)menuPressed:(id)sender {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"SMS",@"Facebook",@"Google+",@"LinkedIn",@"Twitter", nil];
    [menu showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [_testimonial setViewController:self];
    switch (buttonIndex) {
        case 0:
            //Email
            [_testimonial sendEmailInViewController:self];
            break;
        case 1:
            //SMS
            [_testimonial sendSMSInViewController:self];
            break;
        case 2:
            //Facebook
            [_testimonial postToFacebook];
            break;
        case 3:
            //Google+
            [_testimonial refreshInterfaceBasedOnSignIn];
            break;
        case 4:
            //LinkedIn
            [_testimonial initLinkedIn];
            break;
        case 5:
            //Twitter
            [_testimonial postToTwitter];
            break;
        default:
            break;
    }
}

- (IBAction)favoritePressed:(id)sender {
    [HUD show:YES];
    [_testimonial setFavorite];
}

-(void)openUrl{
    if(_testimonial.url.length > 20){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_testimonial.url]];
    }
}

- (IBAction)editPressed:(id)sender {
    AGEditViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"editViewController"];
    vc.record = _testimonial;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark

-(void)getViewsCount{
    JXApiRequest *getViewsCount = [JXApiRequest new];
    getViewsCount.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",GET_VIEWS_COUNT,[[AGThisUser currentUser] getUserAuthToken]];
    [getViewsCount requestWithDomain:APP_DOMAIN methode:method parameters:@{kJsonObjectKey:@{@"record_id":_testimonial.recordId}.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"Response: %@",response);
    BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
    if(result){
        NSString *count = [NSString stringWithFormat:@"%@",response[@"count"]];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Views: " attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:count attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueMedium size:16.],NSForegroundColorAttributeName:[UIColor colorWithWhite:0.475 alpha:1.000]}];
        [str appendAttributedString:str2];
        [_views setAttributedText:str];
    }
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"Error: %@",connectionError);
}
@end
