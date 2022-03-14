//
//  AGStorageOptionsViewController.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGStorageOptionsViewController.h"
#import "AGStorageCell.h"
#import <NXOAuth2AccountStore.h>
#import <NXOAuth2Request.h>
#import <NXOAuth2Account.h>
#import <NXOAuth2Client.h>


static CGFloat const kNormalViewHeight = 120.f;
static CGFloat const kExtendedViewHeight = 305.f;

@interface AGStorageOptionsViewController ()<UITableViewDataSource, UITableViewDelegate, AGStorageCellDelegate>{
    CGFloat keyboardHeight;
    CGRect _tempScrollFrame;
    MBProgressHUD *HUD;
    BOOL _youtubeIsClosed;
    BOOL _vimeIsClosed;
    NSMutableArray *_selectedIndexes;
}
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *allVSS;
@property (nonatomic, strong) NSMutableArray *userVSS;
@property (nonatomic, strong) NSIndexPath *indexPathForSave;

@end

@implementation AGStorageOptionsViewController

-(void)authInVimeo{
    OAuthRequest* request = [OAuthRequest requestWithURL:[NSURL URLWithString:kVimeoAccessTokenRequestURL] consumer:[AGVimeoAuth auth].consumer token:nil realm:nil signerClass:[OAuthSignerHMAC class]];
    [request prepare];
    NSHTTPURLResponse* response;
    NSError* error;
    NSData* receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if([response statusCode] != 200){
        NSLog(@"Error:%@",error);
        return;
    }
    
    NSDictionary* parameters = [NSDictionary dictionaryWithOauthParameters:[[AGVimeoAuth auth] parametersFromData:receivedData]];
    [AGVimeoAuth auth].token = [OAuthToken tokenWithKey:[parameters objectForKey:@"oauth_token"] secret:[parameters objectForKey:@"oauth_token_secret"] authorized:NO];
    NSString *authorizationString = [NSString stringWithFormat:@"http://vimeo.com/oauth/authorize?oauth_token=%@&permission=delete",[parameters objectForKey:@"oauth_token"]];
    NSURL *authoriz = [NSURL URLWithString:authorizationString];

    [[NXOAuth2AccountStore sharedStore] setClientID:kConsumerKey secret:kConsumerSecret authorizationURL:authoriz tokenURL:[NSURL URLWithString:@"https://vimeo.com/oauth/access_token"] redirectURL:[NSURL URLWithString:@"vimeodroid://oauth.done"] forAccountType:@"Vimeo"];
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"Vimeo"];
}

-(void)authInYoutube{
    [[NXOAuth2AccountStore sharedStore] setClientID:kGoogleClientId
                                             secret:kGoogleSecret
                                              scope:[NSSet setWithArray:@[@"https://gdata.youtube.com"]]
                                   authorizationURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/auth?access_type=offline"]
                                           tokenURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/token"]
                                        redirectURL:[NSURL URLWithString:@"com.vocalreferences.1:/oauth2callback2"]
                                      keyChainGroup:@"YoutubeTokens"
                                     forAccountType:@"Youtube"];
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"Youtube"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    [self setFonts];
    
    _youtubeIsClosed = YES;
    _vimeIsClosed = YES;
    _selectedIndexes = [[NSMutableArray alloc] init];
    
    [self loadAllVSS];
}

-(void)viewWillAppear:(BOOL)animated{
    _tempScrollFrame = _tableView.frame;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollTableToEnd:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTableToNormalSize:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveSuccess)
                                                 name:kVSSUploadedSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveFailed)
                                                 name:kVSSUploadedFailed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveStorage)
                                                 name:kVimeoDidReciveOauthTokens
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveStorage)
                                                 name:kYoutubeDidReciveOauthTokens
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProfile)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileUpdated)
                                                 name:@"userUpdated" object:nil];
}

-(void)updateProfile{
    [HUD show:YES];
    [[AGThisUser currentUser] updateProfile];
}

-(void)profileUpdated{
    [HUD hide:YES];
    [_tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setFonts{
    [_backButton thisIsBackButtonWithOptionalFont:nil andColor:nil];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AGApi

-(void)loadAllVSS{
    [HUD show:YES];
    AGApi *getAllVSS = [AGApi new];
    NSString *method = [NSString stringWithFormat:@"%@%@",GET_ALL_VSS,[[AGThisUser currentUser] getUserAuthToken]];
    [getAllVSS GETrequestWithMethode:method parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
        NSLog(@"Success all VSS: %@",response);
        _allVSS = [NSMutableArray new];
        for(NSDictionary *dict in response[kRecords]){
            AGStorage *storage = [[AGStorage alloc] initWithDictionary:dict];
            [_allVSS addObject:storage];
        }
        [self loadUserVSS];
    } failure:^(NSError *error, NSString *errorString) {
        [HUD hide:YES];
        NSLog(@"Error all VSS: %@",error);
    }];
}

-(void)loadUserVSS{
    AGApi *getUserVSS = [AGApi new];
    NSString *method = [NSString stringWithFormat:@"%@%@",GET_USER_VSS,[[AGThisUser currentUser] getUserAuthToken]];
    [getUserVSS GETrequestWithMethode:method parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
        [HUD hide:YES];
        _userVSS = [NSMutableArray new];
        for(NSDictionary *dict in response[kRecords]){
            AGStorage *storage = [[AGStorage alloc] initWithDictionary:dict];
            [_userVSS addObject:storage];
        }
        [_tableView reloadData];
        NSLog(@"Success user VSS: %@",response);
    } failure:^(NSError *error, NSString *errorString) {
        [HUD hide:YES];
        NSLog(@"Error user VSS: %@",error);
    }];
}

#pragma mark - AGStorageCellDelegate

-(void)saveStorageOnOffAtIndexPath:(NSIndexPath *)indexPath{
    _indexPathForSave = indexPath;
    AGStorageCell *cell = (AGStorageCell *)[_tableView cellForRowAtIndexPath:_indexPathForSave];
    if(cell.username.text.length == 0 || cell.password.text.length == 0){
        NSInteger selected = [self indexForSelectedCell:indexPath.row];
        if(selected > -1){
            if(!cell.switcher.isOn){
                [_selectedIndexes removeObjectAtIndex:selected];
            }
        } else {
            [_selectedIndexes addObject:indexPath];
        }
        [_tableView beginUpdates];
        [_tableView endUpdates];
        return;
    }
    AGStorage *storage = (AGStorage*)_allVSS[_indexPathForSave.row];
    AGStorage *userStorage = [self searchInUserVssByVssId:storage.storageId];
    if(userStorage){
        [HUD show:YES];
        userStorage.login = cell.username.text;
        userStorage.password = cell.password.text;
        userStorage.isEnabled = cell.switcher.isOn;
        if(!userStorage.token){
            userStorage.token = @"";
            userStorage.tokenSecret = @"";
        }
        [userStorage editStorage];
    }
}

-(void)editStorage:(NSIndexPath*)indexPath{
    _indexPathForSave = indexPath;
    AGStorageCell *cell = (AGStorageCell *)[_tableView cellForRowAtIndexPath:_indexPathForSave];
    AGStorage *storage = (AGStorage*)_allVSS[_indexPathForSave.row];
    AGStorage *userStorage = [self searchInUserVssByVssId:storage.storageId];
    if(userStorage){
        [HUD show:YES];
        userStorage.login = cell.username.text;
        userStorage.password = cell.password.text;
        userStorage.isEnabled = cell.switcher.isOn;
        if(!userStorage.token){
            userStorage.token = @"";
            userStorage.tokenSecret = @"";
        }
        [userStorage editStorage];
    }
}

-(void)saveChangesForStorageAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Save changes!");
    [HUD show:YES];
    [HUD hide:YES afterDelay:10.f];
    _indexPathForSave = indexPath;
    AGStorage *storage = (AGStorage*)_allVSS[indexPath.row];
    if([storage.storageName isEqualToString:@"vimeo"]){
        [self authInVimeo];
    } else if([storage.storageName isEqualToString:@"youtube"]){
//        [self saveStorage];
//        NSString *urlStr = [NSString stringWithFormat:@"%@user/getYoutubeAccess?auth_token=%@&redirect=com.vocalreferences.1://",YOUTUBE,[[AGThisUser currentUser] getUserAuthToken]];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        [self editStorage:indexPath];
    } else {
        [self saveStorage];
    }
}

-(void)saveStorage{
    AGStorageCell *cell = (AGStorageCell *)[_tableView cellForRowAtIndexPath:_indexPathForSave];
    AGStorage *storage = (AGStorage*)_allVSS[_indexPathForSave.row];
    
    NSString *token;
    NSString *secret;
    if([storage.storageName isEqualToString:@"vimeo"]){
        token = [AGVimeoAuth auth].vimeoAccessToken.key;
        secret = [AGVimeoAuth auth].vimeoAccessToken.secret;
    } else if([storage.storageName isEqualToString:@"youtube"]){
        token = @"";//[AGYoutubeAuth auth].accessToken;
        secret = @"";//[AGYoutubeAuth auth].refreshToken;
    } else {
        token = @"";
        secret = @"";
    }
    
    AGStorage *userStorage = [self searchInUserVssByVssId:storage.storageId];
    if(userStorage){
        userStorage.login = cell.username.text;
        userStorage.password = cell.password.text;
        userStorage.isEnabled = cell.switcher.isOn;
        userStorage.token = token;
        userStorage.tokenSecret = secret;
        [userStorage editStorage];
    } else {
        storage.vssId = storage.storageId;
        storage.login = cell.username.text;
        storage.password = cell.password.text;
        storage.isEnabled = cell.switcher.isOn;
        storage.token = token;
        storage.tokenSecret = secret;
        [storage saveStorage];
    }
}

-(void)linkAccountPressed:(NSIndexPath *)indexPath{
    NSString *urlStr = [NSString stringWithFormat:@"%@user/getYoutubeAccess?auth_token=%@&redirect=com.vocalreferences.1://",YOUTUBE,[[AGThisUser currentUser] getUserAuthToken]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

-(void)saveSuccess{
    [HUD hide:YES];
    NSLog(@"Save success");
}

-(void)saveFailed{
    [HUD hide:YES];
    NSLog(@"Save failed");
}

#pragma mark - TextFields

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Scroll size

-(void)scrollTableToEnd:(NSNotification*)aNotification{
    NSDictionary *keyboardAnimationDetail = [aNotification userInfo];
    NSValue* keyboardFrameBegin = [keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardHeight = keyboardFrameBeginRect.size.height;
    CGRect tableFrame = CGRectMake(0, _tempScrollFrame.origin.y, _tempScrollFrame.size.width, _tempScrollFrame.size.height-keyboardFrameBeginRect.size.height);
    _tableView.frame = tableFrame;
}

-(void)setTableToNormalSize:(NSNotification*)aNotification{
    _tableView.frame = _tempScrollFrame;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _allVSS.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AGStorageCell *cell = (AGStorageCell*)[tableView dequeueReusableCellWithIdentifier:@"storageCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AGStorage *stor = (AGStorage *)_allVSS[indexPath.row];
    [cell.storageIcon sd_setImageWithURL:[NSURL URLWithString:stor.logoPath]];
    
    cell.regURL = stor.registrationUrl;
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    AGStorage *userStorage = [self searchInUserVssByVssId:stor.storageId];
    if(userStorage){
        cell.username.text = userStorage.login;
        cell.password.text = userStorage.password;
        [cell.switcher setOn:userStorage.isEnabled];
    }
    
    if([stor.storageName isEqualToString:@"youtube"]){
        [cell youtubeCell];
        NSString *status;
        if([AGThisUser currentUser].isLinked){
            status = [NSString stringWithFormat:@"Linked (%@)",[AGThisUser currentUser].youtubeLinkedTo];
        } else {
            status = @"Not Linked";
        }
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@"YouTube Account Link Status:\n" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.475 green:0.475 blue:0.482 alpha:1.000], NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueRegular size:13.]}];
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:status attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.600 green:0.800 blue:0.000 alpha:1.000], NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueRegular size:13.]}];
        [str1 appendAttributedString:str2];
        
        [cell.storageText setAttributedText:str1];
    } else {
        [cell defaultCell];
        [cell.storageText setAttributedText:nil];
        cell.storageText.text = [NSString stringWithFormat:@"Enter your %@ account",stor.storageName];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AGStorageCell *cell = (AGStorageCell *)[_tableView cellForRowAtIndexPath:_indexPathForSave];
    if(cell.username.text.length == 0 || cell.password.text.length == 0){
        [cell.switcher setOn:NO];
    }
    NSInteger selected = [self indexForSelectedCell:indexPath.row];
    if(selected > -1){
        [_selectedIndexes removeObjectAtIndex:selected];
    } else {
        [_selectedIndexes addObject:indexPath];
    }
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

-(NSInteger)indexForSelectedCell:(NSInteger)index{
    BOOL found = NO;
    int ind = -1;
    for(NSIndexPath *indexPath in _selectedIndexes){
        ind++;
        if(indexPath.row == index){
            found = YES;
            break;
        }
    }
    if(!found) ind = -1;
    return ind;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Indexes: %@",_selectedIndexes);
    NSInteger selected = [self indexForSelectedCell:indexPath.row];
    if(selected > -1){
        AGStorage *stor = (AGStorage *)_allVSS[indexPath.row];
        if([stor.storageName isEqualToString:@"youtube"]){
            return 233.f;
        } else {
            return kExtendedViewHeight;
        }
    } else {
        return kNormalViewHeight;
    }
}

-(AGStorage*)searchInUserVssByVssId:(NSString*)vssId{
    for(AGStorage *storage in _userVSS){
        if([storage.vssId isEqualToString:vssId]){
            return storage;
        }
    }
    return nil;
}
@end
