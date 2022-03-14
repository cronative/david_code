//
//  AGEditViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 10.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGEditViewController.h"
#import "AGExpandableTextView.h"

@interface AGEditViewController ()<UITextFieldDelegate, UIScrollViewDelegate, AGExpandableTextDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    CGFloat keyboardHeight;
    CGRect _tempScrollFrame;
    MBProgressHUD *HUD;
    BOOL _isLocal;
    BOOL _imageAdded;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *saveAsdefaultButton;

@property (nonatomic, strong) UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
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
//@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *fieldsView;

@property (nonatomic, strong) UIView *viewForBodyText;

@property (nonatomic, strong) AGExpandableTextView *textBody;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

@end

@implementation AGEditViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFonts];
    
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    if(_testimonial){
        _isLocal = YES;
    } else {
        _isLocal = NO;
    }
    (_isLocal)?[self setupForLocal]:[self setupForRecord];
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //[self setupScroll];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editDone) name:kRecordEdited object:nil];
    
    [self setupScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
    [_doneButton applyAwesomeFontWithSize:26.];
    [[_doneButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_doneButton setImage:[[UIImage imageNamed:@"Circular-tick-done@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_doneButton setTintColor:[UIColor whiteColor]];
    
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
    
//    _dateView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
//    _dateView.layer.shadowOffset = CGSizeMake(0., 1.f);
//    _dateView.layer.shadowOpacity = 1.;
//    _dateView.layer.shadowRadius = 1.f;
}

-(void)setupScroll{
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _fieldsView.frame.origin.y+_fieldsView.frame.size.height);
    CGRect tempFrame = _scrollView.frame;
    tempFrame.size.height = SCREEN_HEIGHT-64;
    _scrollView.frame = tempFrame;
    _tempScrollFrame = _scrollView.frame;
}

#pragma mark - Setup views

-(void)setupForLocal{
    if(_testimonial.image && (_testimonial.type.integerValue == AudioTestimonial || _testimonial.type.integerValue == TextTestimonial)){
        _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_WIDTH*250/450)];
        [_imageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageButton.imageView setClipsToBounds:YES];
        [_imageButton setImage:[UIImage imageWithData:_testimonial.image] forState:UIControlStateNormal];
        [_imageButton addTarget:self action:@selector(addImagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_imageButton];
        
//        CGRect dateFrame = _dateView.frame;
//        dateFrame.origin.y = _imageButton.frame.size.height + 20;
//        _dateView.frame = dateFrame;
        
        CGRect titleFrame = _titleView.frame;
        titleFrame.origin.y = _imageButton.frame.size.height + 20;
        _titleView.frame = titleFrame;
    }
    
    if(_testimonial.type.integerValue == TextTestimonial){
        [self setupTextField];
    } else {
        CGRect temp = _fieldsView.frame;
        temp.origin.y = _titleView.frame.origin.y+_titleView.frame.size.height+10;
        _fieldsView.frame = temp;
    }
    _testimonialTitle.text = _testimonial.title;
    _companyName.text = _testimonial.companyName;
    _phoneNumber.text = _testimonial.phoneNumber;
    _website.text = _testimonial.website;
    _keywords.text = _testimonial.keywords;
    _descript.text = _testimonial.descript;
    _customer.text = _testimonial.customer;
    _customerEmail.text = _testimonial.customerEmail;
    _dateLabel.text = [self stringFromDate:_testimonial.date];
}

-(void)setupForRecord{
    if(_record.picturePath.length > 20 && (_record.recordType == AudioTestimonial || _record.recordType == TextTestimonial)){
        _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_WIDTH*250/450)];
        [_imageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageButton.imageView setClipsToBounds:YES];
        [_imageButton.imageView sd_setImageWithURL:[NSURL URLWithString:_record.picturePath] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_imageButton setImage:image forState:UIControlStateNormal];
        }];
        [_imageButton addTarget:self action:@selector(addImagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_imageButton];
        
//        CGRect dateFrame = _dateView.frame;
//        dateFrame.origin.y = _imageButton.frame.size.height + 20;
//        _dateView.frame = dateFrame;
        
        CGRect titleFrame = _titleView.frame;
        titleFrame.origin.y = _imageButton.frame.size.height + 20;
        _titleView.frame = titleFrame;
    }
    
    if(_record.recordType == TextTestimonial){
        [self setupTextField];
    } else {
        CGRect temp = _fieldsView.frame;
        temp.origin.y = _titleView.frame.origin.y+_titleView.frame.size.height+10;
        _fieldsView.frame = temp;
    }
    _testimonialTitle.text = _record.title;
    _companyName.text = _record.companyName;
    _phoneNumber.text = _record.phoneNumber;
    _website.text = _record.website;
    _keywords.text = _record.keywords;
    _descript.text = _record.descript;
    _customer.text = _record.customer;
    _customerEmail.text = _record.customerEmail;
    _dateLabel.text = [self convertDate:_record.updatedAt];
}

-(NSString *)convertDate:(NSString*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateU = [dateFormatter dateFromString:date];
    return [self stringFromDate:dateU];
}

-(NSString *)stringFromDate:(NSDate*)date{
    NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"dd-MMM-yy hh:mma"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    _dateFormatter.locale = usLocale;
    return [_dateFormatter stringFromDate:date];
}

#pragma mark - Expandable text view

-(void)setupTextField{
    _viewForBodyText = [[UIView alloc] initWithFrame:CGRectMake(10, _titleView.frame.size.height+_titleView.frame.origin.y+10, SCREEN_WIDTH-20,40)];
    _viewForBodyText.backgroundColor = [UIColor whiteColor];
    _viewForBodyText.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _viewForBodyText.layer.shadowOffset = CGSizeMake(0., 1.f);
    _viewForBodyText.layer.shadowOpacity = 1.;
    _viewForBodyText.layer.shadowRadius = 1.f;
    [_viewForBodyText setAutoresizesSubviews:YES];
    
    [_scrollView addSubview:_viewForBodyText];
    
    _textBody = [[AGExpandableTextView alloc] initWithFrame:CGRectMake(15, 0, _viewForBodyText.frame.size.width-30,50)];
    _textBody.placeholderLabel.text = @"Text";
    CGRect placeholder = _textBody.placeholderLabel.frame;
    placeholder.origin.y = placeholder.origin.y-6;
    _textBody.placeholderLabel.frame = placeholder;
    [_textBody.placeholderLabel setHidden:YES];
    _textBody.textView.text = (_isLocal)?_testimonial.text:_record.textBody;
    _textBody.textView.font = [UIFont fontWithName:kHelveticaNeueRegular size:18.f];
    _textBody.textView.textColor = [UIColor colorWithRed:0.475 green:0.475 blue:0.482 alpha:1.000];
    _textBody.delegate = self;
    
    [_viewForBodyText addSubview:_textBody];
    
    
    CGRect temp = _viewForBodyText.frame;
    if(_textBody.frame.size.height > 40){
        temp.size.height = _textBody.frame.size.height + 5;
    } else {
        temp.size.height = _textBody.frame.size.height;
    }
    _viewForBodyText.frame = temp;
    
    temp = _textBody.frame;
    temp.size.height = _viewForBodyText.frame.size.height;
    _textBody.frame = temp;
    
    temp = _fieldsView.frame;
    temp.origin.y = _viewForBodyText.frame.origin.y+_viewForBodyText.frame.size.height+10;
    _fieldsView.frame = temp;
    
    _tempScrollFrame = _scrollView.frame;
}

-(void)textViewDidChangeHeight:(CGFloat)height{
    CGRect temp = _fieldsView.frame;
    temp.origin.y = _viewForBodyText.frame.origin.y+_viewForBodyText.frame.size.height+10;
    _fieldsView.frame = temp;
    
    temp = _viewForBodyText.frame;
    if(_textBody.frame.size.height > 40){
        temp.size.height = _textBody.frame.size.height + 5;
    } else {
        temp.size.height = _textBody.frame.size.height;
    }
    _viewForBodyText.frame = temp;
    
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _fieldsView.frame.origin.y+_fieldsView.frame.size.height);
    
    [_textBody.textView setContentOffset:CGPointMake(0.f, 0.05f) animated:YES];
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

#pragma mark - textField 

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

#pragma mark - Saving

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

- (IBAction)savePressed:(id)sender {
    if(_isLocal){
        [self saveTestimonialToDB];
    } else {
        [self saveToBackend];
    }
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

    _testimonial.date = [NSDate date];
    _testimonial.text = (_textBody)?_textBody.textView.text:@"";
    _testimonial.title = _testimonialTitle.text;
    _testimonial.companyName = _companyName.text;
    _testimonial.phoneNumber = _phoneNumber.text;
    _testimonial.website = _website.text;
    _testimonial.keywords = _keywords.text;
    _testimonial.descript = _descript.text;
    _testimonial.customer = _customer.text;
    _testimonial.customerEmail = _customerEmail.text;
    if(_imageAdded){
        _testimonial.image = UIImageJPEGRepresentation([_imageButton imageForState:UIControlStateNormal], 1.f);
    }
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        NSLog(@"Testimonial saved in DB!");
        [[NSNotificationCenter defaultCenter] postNotificationName:kPopToMain object:nil];
    }
}

#pragma mark - UIImagePickerController

- (void)addImagePressed:(id)sender {
    UIActionSheet *chooser = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Camera Roll", nil];
    chooser.tag = 1231;
    [chooser showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 1231){
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
    [_imageButton setImage:[info objectForKey:UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^{
        _imageAdded = YES;
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Save to backend

-(void)saveToBackend{
    _record.textBody = (_textBody)?_textBody.textView.text:@"";
    _record.title = _testimonialTitle.text;
    _record.companyName = _companyName.text;
    _record.phoneNumber = _phoneNumber.text;
    _record.website = _website.text;
    _record.keywords = _keywords.text;
    _record.descript = _descript.text;
    _record.customer = _customer.text;
    _record.customerEmail = _customerEmail.text;
    
    [HUD show:YES];
    if(_imageAdded){
        [self uploadTestimonial];
    } else {
        [_record edit];
    }
}

-(void)uploadTestimonial{
    AGApi *getLink = [AGApi new];
    [getLink POSTrequestWith:GET_CLOUD_LINK parameters:nil success:^(id response, id wrongObject) {
        NSLog(@"Success CLOUD: %@",response);
        NSString *path = response[@"link"];
        [self uploadWithLink:path];
    } failure:^(NSError *error, NSString *errorString) {
        NSLog(@"Failure cloud: %@",error);
        [HUD hide:YES];
    }];
}

-(void)uploadWithLink:(NSString *)url{
    __block NSString *filename;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *image = UIImageJPEGRepresentation([_imageButton imageForState:UIControlStateNormal], 1.f);
        filename = [NSString stringWithFormat:@"%@.jpg",url.lastPathComponent];
        [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
        [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"filename"];
        [formData appendPartWithFileData:image name:@"file" fileName:filename mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [HUD hide:YES];
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@",operation.responseString);
        NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        NSString *file = json[@"filePath"];
        NSLog(@"Filename: %@",file);
        _record.picturePath = file;
        [_record edit];
    }];
}

-(void)editDone{
    [HUD hide:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPopToMain object:nil];
}
@end
