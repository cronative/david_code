//
//  AGRecord.m
//  VocalReferences
//
//  Created by Andrey Golovin on 04.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGRecord.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <LIALinkedInApplication.h>
#import <LIALinkedInHttpClient.h>
#import "XMLReader.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FacebookSDK/FacebookSDK.h>

#define kShareTag 101

NSString *const kNeedToUpdateListOfRecords = @"needToUpdateRecords";
NSString *const kRecordEdited = @"editedRecord";

@interface AGRecord()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, GPPSignInDelegate, FBSDKSharingDelegate>{
    GPPSignIn *signIn;
}

@property (nonatomic, weak) UIViewController *viewController;

@end

@implementation AGRecord

-(instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if(self){
        _companyName = [[NSString stringWithFormat:@"%@",dict[@"companyName"]] stringWithoutNull];
        _correctedUrl = [[NSString stringWithFormat:@"%@",dict[@"corrected_url"]] stringWithoutNull];
        _createdAt = [[NSString stringWithFormat:@"%@",dict[@"created_at"]] stringWithoutNull];
        _customer = [[NSString stringWithFormat:@"%@",dict[@"customer"]] stringWithoutNull];
        _customerEmail = [[NSString stringWithFormat:@"%@",dict[@"customerEmail"]] stringWithoutNull];
        _descript = [[[NSString stringWithFormat:@"%@",dict[@"description"]] stringWithoutNull] stringByStrippingHTML];
        _googleCloudLink = [[NSString stringWithFormat:@"%@",dict[@"google_clude_file_name"]] stringWithoutNull];
        _recordId = [[NSString stringWithFormat:@"%@",dict[@"id"]] stringWithoutNull];
        _isFavorite = [NSString stringWithFormat:@"%@",dict[@"isFavorite"]].boolValue;
        _keywords = [[NSString stringWithFormat:@"%@",dict[@"keywords"]] stringWithoutNull];
        _phoneNumber = [[NSString stringWithFormat:@"%@",dict[@"phoneNumber"]] stringWithoutNull];
        _picturePath = [[NSString stringWithFormat:@"%@",dict[@"picture_path"]] stringWithoutNull];
        _previewImage = [[NSString stringWithFormat:@"%@",dict[@"preview_image"]] stringWithoutNull];
        _recordType = [NSString stringWithFormat:@"%@",dict[@"record_type"]].integerValue;
        _status = [NSString stringWithFormat:@"%@",dict[@"status"]].integerValue;
        _textBody = [[NSString stringWithFormat:@"%@",dict[@"text_body"]] stringByStrippingHTML];
        _title = [[NSString stringWithFormat:@"%@",dict[@"title"]] stringByStrippingHTML];
        _updatedAt = [[NSString stringWithFormat:@"%@",dict[@"updated_at"]] stringWithoutNull];
        _url = [[NSString stringWithFormat:@"%@",dict[@"url"]] stringWithoutNull];
        _userId = [[NSString stringWithFormat:@"%@",dict[@"user_id"]] stringWithoutNull];
        _vssId = [[NSString stringWithFormat:@"%@",dict[@"vss_id"]] stringWithoutNull];
        _vssThumbnail = [[NSString stringWithFormat:@"%@",dict[@"vss_thumbnail"]] stringWithoutNull];
        _website = [[NSString stringWithFormat:@"%@",dict[@"website"]] stringWithoutNull];
        _countViews = [[NSString stringWithFormat:@"%@",dict[@"count_views"]] stringWithoutNull];
    }
    return self;
}

-(void)remove{
    JXApiRequest *remove = [JXApiRequest new];
    remove.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",DELETE_RECORD,[[AGThisUser currentUser] getUserAuthToken]];
    [remove requestWithDomain:APP_DOMAIN methode:method parameters:@{kJsonObjectKey:@{@"record_id":_recordId}.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

-(void)setFavorite{
    JXApiRequest *setFavorite = [JXApiRequest new];
    setFavorite.tag = 123;
    setFavorite.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",SET_FAVORITE,[[AGThisUser currentUser] getUserAuthToken]];
    [setFavorite requestWithDomain:APP_DOMAIN methode:method parameters:@{kJsonObjectKey:@{@"record_id":_recordId,@"isFavorite":[NSNumber numberWithBool:!_isFavorite]}.JSON} photoContent:nil videoContent:nil audioContent:nil];
}

-(void)apiRequest:(JXApiRequest *)request didReciveResponse:(NSDictionary *)response{
    NSLog(@"Response %@",response);
    BOOL result = [NSString stringWithFormat:@"%@",response[@"result"]].boolValue;
    if(result){
        if(request.tag == 123){
            _isFavorite = !_isFavorite;
        }
        if(request.tag == 911){
            [[NSNotificationCenter defaultCenter] postNotificationName:kRecordEdited object:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedToUpdateListOfRecords object:nil];
    }
}

-(void)apiRequest:(JXApiRequest *)request finishWithConnectionError:(NSError *)connectionError{
    NSLog(@"ERROR: %@",connectionError);
}

#pragma mark - Sharing
-(void)shareInViewController:(UIViewController *)viewController{
    _viewController = viewController;
    UIActionSheet *share = [[UIActionSheet alloc] initWithTitle:@"Share via..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Google+",@"LinkedIn",@"Twitter", nil];
    share.tag = kShareTag;
    [share showInView:[UIApplication sharedApplication].windows[0]];
}

-(void)setViewController:(UIViewController*)viewController{
    _viewController = viewController;
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //Facebook
            [self postToFacebook];
            break;
        case 1:
            //Google+
            [self refreshInterfaceBasedOnSignIn];
            break;
        case 2:
            //LinkedIn
            [self initLinkedIn];
            break;
        case 3:
            //Twitter
            [self postToTwitter];
            break;
        default:
            break;
    }
}

-(void)sendSMSInViewController:(UIViewController*)viewController{
    if([_url isEqualToString:@"<null>"] || [_url isEqualToString:@"(null)"]){
        _url = @"";
    }
    _viewController = viewController;
    NSString *body = [self createMassageBody:NO tweeter:NO];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = body;
        controller.recipients = nil;
        controller.messageComposeDelegate = self;
        [_viewController presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [_viewController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)sendEmailInViewController:(UIViewController*)viewController{
    if([_url isEqualToString:@"<null>"] || [_url isEqualToString:@"(null)"]){
        _url = @"";
    }
    _viewController = viewController;
    NSString *body = [self createMassageBody:YES tweeter:NO];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        NSString *subject;
        if(_companyName.length > 0){
            subject = [NSString stringWithFormat:@"Testimonial for %@",_companyName];
        } else {
            subject = @"Testimonial";
        }
        [picker setSubject:subject];
        [picker setMessageBody:body isHTML:YES];
        [_viewController presentViewController:picker animated:YES completion:NULL];
    } else {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!",nil) message:NSLocalizedString(@"Setup email in settings",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles: nil];
        [error show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [_viewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Facebook

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"Shared with result: %@",results);
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"Error: %@",error);
}

-(void)postToFacebook
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:_url];
    if(_url.length == 0){
        content.imageURL = [NSURL URLWithString:_picturePath];
    }
    content.contentTitle = _title;
     NSMutableString *body = [NSMutableString new];
    if(_textBody.length > 0){
        [body appendFormat:@"%@\" *",_textBody];
    }
    
    if([AGThisUser currentUser].firstName.length > 0){
        [body appendFormat:@"From %@",[AGThisUser currentUser].firstName];
    }
    if([AGThisUser currentUser].lastName.length > 0){
        if(body.length > 0){
            [body appendFormat:@" %@",[AGThisUser currentUser].lastName];
        } else {
            [body appendFormat:@"%@",[AGThisUser currentUser].lastName];
        }
    }

    
    if(_companyName.length > 0){
        [body appendFormat:@" * Company: %@ ",_companyName];
    }
    if(_phoneNumber.length > 0){
        [body appendFormat:@"* Phone: %@ ",_phoneNumber];
    }
    if(_website.length > 0){
        [body appendFormat:@"* Website: %@ ",_website];
    }
    if(_customerEmail.length > 0){
        [body appendFormat:@"* Email: %@",_customerEmail];
    }
    [body appendString:@"* Powered By VocalReferences *  http://www.vocalreferences.com"];
    
    content.contentDescription = body;
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    [shareDialog show];
}

#pragma mark - Twitter

-(NSString *)createMassageBody:(BOOL)isEmail tweeter:(BOOL)isTweet{
    NSMutableString *body = [NSMutableString new];
    if(isEmail){
        if(_title.length > 0){
            body = [NSMutableString stringWithFormat:@"%@",_title];
        }
        if(_textBody.length > 0){
            [body appendFormat:@"</br>\"%@\"</br></br>",_textBody];
        } else if(_recordType == VideoTestimonial){
            [body appendFormat:@"</br><a href=\"%@\">Video</a></br></br>",_url];
        } else if(_recordType == AudioTestimonial){
            [body appendFormat:@"</br><a href=\"%@\">Audio</a></br></br>",_url];
        }
        
        if([AGThisUser currentUser].firstName.length > 0){
            [body appendFormat:@"%@",[AGThisUser currentUser].firstName];
        }
        if([AGThisUser currentUser].lastName.length > 0){
            if(body.length > 0){
                [body appendFormat:@" %@",[AGThisUser currentUser].lastName];
            } else {
                [body appendFormat:@"%@",[AGThisUser currentUser].lastName];
            }
        }
        if([AGThisUser currentUser].city.length > 0){
            if(body.length > 0){
                [body appendFormat:@", %@ ",[AGThisUser currentUser].city];
            } else {
                [body appendFormat:@"%@",[AGThisUser currentUser].city];
            }
        }
        if([AGThisUser currentUser].state.length > 0){
            if(body.length > 0){
                [body appendFormat:@", %@ ",[AGThisUser currentUser].state];
            } else {
                [body appendFormat:@"%@",[AGThisUser currentUser].state];
            }
        }
        
        if(_companyName.length > 0){
            [body appendFormat:@"Company: %@</br>",_companyName];
        }
        if(_phoneNumber.length > 0){
            [body appendFormat:@"Phone: %@</br>",_phoneNumber];
        }
        if(_website.length > 0){
            [body appendFormat:@"Website: %@</br>",_website];
        }
        if(_customerEmail.length > 0){
            [body appendFormat:@"Email: %@</br>",_customerEmail];
        }
        [body appendString:@"</br><a href=\"http://www.vocalreferences.com\">Powered By VocalReferences</a>\n"];
    } else if(_recordType == TextTestimonial && !isTweet){
        if(_title.length > 0){
            body = [NSMutableString stringWithFormat:@"%@",_title];
        }
        if(_textBody.length > 0){
            [body appendFormat:@"\n\"%@\"\n\n",_textBody];
        } else {
            [body appendString:@"\n\n"];
        }
        
        if([AGThisUser currentUser].firstName.length > 0){
            [body appendFormat:@"%@",[AGThisUser currentUser].firstName];
        }
        if([AGThisUser currentUser].lastName.length > 0){
            if(body.length > 0){
                [body appendFormat:@" %@",[AGThisUser currentUser].lastName];
            } else {
                [body appendFormat:@"%@",[AGThisUser currentUser].lastName];
            }
        }
        if([AGThisUser currentUser].city.length > 0){
            if(body.length > 0){
                [body appendFormat:@", %@ ",[AGThisUser currentUser].city];
            } else {
                [body appendFormat:@"%@",[AGThisUser currentUser].city];
            }
        }
        if([AGThisUser currentUser].state.length > 0){
            if(body.length > 0){
                [body appendFormat:@", %@ ",[AGThisUser currentUser].state];
            } else {
                [body appendFormat:@"%@",[AGThisUser currentUser].state];
            }
        }

        if(_companyName.length > 0){
            [body appendFormat:@"Company: %@\n",_companyName];
        }
        if(_phoneNumber.length > 0){
            [body appendFormat:@"Phone: %@\n",_phoneNumber];
        }
        if(_website.length > 0){
            [body appendFormat:@"Website: %@\n",_website];
        }
        if(_customerEmail.length > 0){
            [body appendFormat:@"Email: %@\n",_customerEmail];
        }
        [body appendString:@"\nPowered By VocalReferences\n"];
        [body appendString:@"http://www.vocalreferences.com"];
    } else if(isTweet){
        if(_title.length > 0){
            body = [NSMutableString stringWithFormat:@"%@",_title];
        }
        if(_textBody.length > 0){
            [body appendFormat:@"\n\"%@\"\n",_textBody];
        } else {
            [body appendString:@"\n"];
        }
        if(_url.length > 0){
            [body appendFormat:@"\n%@",_url];
        }
    } else {
        if(_title.length > 0){
            body = [NSMutableString stringWithFormat:@"%@",_title];
        }
        if(_textBody.length > 0){
            [body appendFormat:@"\n\"%@\"\n\n",_textBody];
        } else {
            [body appendString:@"\n\n"];
        }
        
        if(_companyName.length > 0){
            [body appendFormat:@"Company: %@\n",_companyName];
        }
        if(_phoneNumber.length > 0){
            [body appendFormat:@"Phone: %@\n",_phoneNumber];
        }
        if(_website.length > 0){
            [body appendFormat:@"Website: %@\n",_website];
        }
        if(_customerEmail.length > 0){
            [body appendFormat:@"Email: %@\n",_customerEmail];
        }
//        if(_url.length > 0){
//            [body appendFormat:@"\n%@",_url];
//        }
        [body appendString:@"\n\nPowered By VocalReferences\n"];
        [body appendString:@"http://www.vocalreferences.com"];
    }
    return (NSString*)body;
}

-(void)postToTwitter{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString *body = [self createMassageBody:NO tweeter:YES];
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:body];
        //[composeController addImage:imageToShare];
        if(_url.length > 0){
            [composeController addURL: [NSURL URLWithString:_url]];
        }
        
        [_viewController presentViewController:composeController
                           animated:YES completion:nil];
    }  else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!",nil) message:NSLocalizedString(@"Please add your twitter account in the phone's settings.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles: nil];
        [alert show];
    }
    
}

#pragma mark --------- Share to google+

-(void)shareToGoogle{
    if([_url isEqualToString:@"<null>"] || [_url isEqualToString:@"(null)"]){
        _url = @"";
    }
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];

    NSString *body = [self createMassageBody:NO tweeter:NO];
    if(_url.length > 0){
        [shareBuilder setURLToShare:[NSURL URLWithString:_url]];
    }
    [shareBuilder setPrefillText:body];

    
    [shareBuilder open];
}

-(void)refreshInterfaceBasedOnSignIn
{
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = kGoogleClientId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.delegate = self;
    if ([[GPPSignIn sharedInstance] authentication]) {
        NSLog(@"Signied");
        // The user is signed in.
        //Share to google+
        // Perform other actions here, such as showing a sign-out button
        [self shareToGoogle];
    } else {
        NSLog(@"Auth!");
        [signIn authenticate];
        // Perform other actions here
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if(error){
        NSLog(@"Received error %@ and auth object %@",error, auth);
    } else {
        [self shareToGoogle];
    }
    
}
- (void)didDisconnectWithError:(NSError *)error{
    NSLog(@"Disconnect  %@",error);
}

#pragma mark - LinkedIn

-(void)initLinkedIn{
    if([_url isEqualToString:@"<null>"] || [_url isEqualToString:@"(null)"]){
        _url = @"";
    }
//    return; //Need redirectURL
    
    [[self getClient] getAuthorizationCode:^(NSString *code) {
        [[self getClient] getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [self shareWithToken:accessToken];
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
    
}

- (void)shareWithToken:(NSString *)accessToken {
    NSString *body = [self createMassageBody:NO tweeter:NO];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[NSDictionary alloc]
                             initWithObjectsAndKeys:
                             @"anyone",@"code",nil], @"visibility",
                            
                            [[NSDictionary alloc]
                             initWithObjectsAndKeys:
                             _title,@"title",
                             _descript,@"description",
                             (_url.length>0)?_url:_picturePath,@"submitted-url",
                             _picturePath,@"submitted-image-url",
                             nil], @"content",
                            
                            
                            body, @"comment", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];

    [manager POST:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/shares?oauth2_access_token=%@", accessToken] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success share: %@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed share: %@",error);
        NSLog(@"Share operation: %@",operation.responseString);
        NSError *err = nil;
        NSDictionary *response = [XMLReader dictionaryForXMLString:operation.responseString error:&err];
        NSLog(@"Share response: %@",response);
        if(response[@"update"]){
            NSLog(@"Share success!");
        } else {
            NSLog(@"Share error!");
            NSString *errorString = [NSString stringWithFormat:@"%@",response[@"error"][@"message"][@"text"]];
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil
                                  ];
            [errorAlert show];
        }
    }];
}

-(LIALinkedInHttpClient*)getClient{
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.jelvix.com"
                                                                                    clientId:@"78ehviix32hx9d"
                                                                                clientSecret:@"UWhXWihqKmjBzpoc"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_basicprofile", @"rw_nus"]];
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

#pragma mark - Edit

-(void)edit{
    JXApiRequest *edit = [JXApiRequest new];
    edit.tag = 911;
    edit.delegate = self;
    NSString *method = [NSString stringWithFormat:@"%@%@",EDIT_RECORD,[[AGThisUser currentUser] getUserAuthToken]];
    [edit requestWithDomain:APP_DOMAIN methode:method parameters:[self paramsForEdit] photoContent:nil videoContent:nil audioContent:nil];
}

-(NSDictionary *)paramsForEdit{
    NSString *recType = [NSString stringWithFormat:@"%d",_recordType];
    NSString *isFavor = [NSString stringWithFormat:@"%d",_isFavorite];
    NSDictionary *params = @{@"record_id":_recordId,@"title":_title,@"description":_descript,@"text_body":_textBody,@"url":_url,@"keywords":_keywords,@"companyName":_companyName,@"website":_website,@"customer":_customer,@"phoneNumber":_phoneNumber,@"customerEmail":_customerEmail,@"record_type":recType,@"picture_path":_picturePath,@"isFavorite":isFavor};
    return @{kJsonObjectKey:params.JSON};
}
@end
