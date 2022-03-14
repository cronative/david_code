//
//  AGRecordTextViewController.m
//  VocalReferences
//
//  Created by Andrey on 19.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGRecordTextViewController.h"
#import "AGExpandableTextView.h"
#import "AGReferenceDetailsViewController.h"

static NSInteger const kChooseFromActionSheet = 12;

@interface AGRecordTextViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, AGExpandableTextDelegate>{
    CGFloat keyboardHeight;
    CGRect _tempScrollFrame;
    BOOL _imageAdded;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) AGExpandableTextView *descript;
@property (weak, nonatomic) IBOutlet UIView *content;
@property (weak, nonatomic) IBOutlet UILabel *line;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *hiddenButton;

@end

@implementation AGRecordTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    [self setUpViews];
    [self setupTextField];
    
    _content.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _content.layer.shadowOffset = CGSizeMake(2., 2.f);
    _content.layer.shadowOpacity = 0.3;
    _content.layer.shadowRadius = 2.f;
}

-(void)viewWillAppear:(BOOL)animated{
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollTableToEnd:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTableToNormalSize:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    [_doneButton applyAwesomeFontWithSize:18.];
    [_cancelButton applyAwesomeFontWithSize:18.];
    
    [[_doneButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_doneButton setImage:[[UIImage imageNamed:@"Circular-tick-done@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_doneButton setTintColor:[UIColor colorWithRed:0.600 green:0.800 blue:0.000 alpha:1.000]];
    
    [[_cancelButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_cancelButton setImage:[[UIImage imageNamed:@"cancelIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_cancelButton setTintColor:[UIColor colorWithRed:1.000 green:0.267 blue:0.267 alpha:1.000]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setup views

-(void)setUpViews{
    _imageView.frame = CGRectMake(0, 0, _content.frame.size.width, _content.frame.size.width*250/450);
    _hiddenButton.frame = _imageView.frame;
}

#pragma mark - ExpandableTextView

-(void)setupTextField{
    CGRect contentRect = _content.frame;
    contentRect.size.height = 40 + _imageView.frame.size.height+10+64;
    _content.frame = contentRect;
    
    _descript = [[AGExpandableTextView alloc] initWithFrame:CGRectMake(10, _imageView.frame.size.height+10, _content.frame.size.width-20,40)];
    _descript.placeholderLabel.text = @"Text";
    _descript.delegate = self;
    [_content addSubview:_descript];
    
    _tempScrollFrame = _scrollView.frame;
    
    CGRect lineRect = _line.frame;
    lineRect.origin.y = _descript.frame.origin.y+40;
    _line.frame = lineRect;

}

-(void)textViewDidChangeHeight:(CGFloat)height{
    CGRect lineRect = _line.frame;
    lineRect.origin.y = _descript.frame.origin.y+height;
    CGFloat distance = _content.frame.size.height - (height+_descript.frame.origin.y);
    CGRect contentRect = _content.frame;
    if(distance < 64){
        contentRect.size.height = height + _descript.frame.origin.y+64;
    }

    _line.frame = lineRect;
    _content.frame = contentRect;

    _scrollView.contentSize = CGSizeMake(ScreenWidth(), _content.frame.size.height+_content.frame.origin.y+10);
    CGPoint bottomOffset = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
    [_scrollView setContentOffset:bottomOffset animated:YES];

}

-(void)scrollTableToEnd:(NSNotification*)aNotification{
    NSDictionary *keyboardAnimationDetail = [aNotification userInfo];
    NSValue* keyboardFrameBegin = [keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect tableFrame = CGRectMake(0, _tempScrollFrame.origin.y, _tempScrollFrame.size.width, _tempScrollFrame.size.height-keyboardFrameBeginRect.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        _scrollView.frame = tableFrame;
    } completion:^(BOOL finished) {
    }];
}

-(void)setTableToNormalSize:(NSNotification*)aNotification{
    [UIView animateWithDuration:0.1 animations:^{
        _scrollView.frame = _tempScrollFrame;
    } completion:^(BOOL finished) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }];
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
    [_imageView setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:^{
        _imageAdded = YES;
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Done

- (IBAction)donePressed:(id)sender {
    if(_descript.textView.text.length == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Text is empty." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    AGReferenceDetailsViewController *ref = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"referenceDetails"];
    ref.testimonialType = TextTestimonial;
    ref.text = _descript.textView.text;
    if(_imageView.image){
        if(_imageAdded){
            ref.image = UIImageJPEGRepresentation(_imageView.image, 1.);
        } else {
            ref.image = UIImageJPEGRepresentation([UIImage imageNamed:@"text_image"], 1.);
        }
    }
    [self.navigationController pushViewController:ref animated:YES];
}

@end
