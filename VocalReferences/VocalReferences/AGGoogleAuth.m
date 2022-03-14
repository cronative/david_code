//
//  AGGoogleAuth.m
//  VocalReferences
//
//  Created by Andrey Golovin on 13.04.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGGoogleAuth.h"
#import <GooglePlus/GPPURLHandler.h>
@interface AGGoogleAuth()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation AGGoogleAuth

-(void)awakeFromNib{
    _closeButton.layer.cornerRadius = 15.f;
    _closeButton.layer.masksToBounds = YES;
    [_closeButton applyAwesomeFontWithSize:16.f];
}

- (IBAction)closePressed:(id)sender {
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HideAllHuds object:nil];
        [self removeFromSuperview];
    }];
}

-(void)openUrl:(NSURL*)url{
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        self.alpha = 1.f;
    }];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"OPEN:!! %@",[[request URL] absoluteString] );
    if ([[[request URL] absoluteString] hasPrefix:@"com.vocalreferences.1:/oauth2callback"]) {
        [GPPURLHandler handleURL:[request URL] sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        
        // Looks like we did log in (onhand of the url), we are logged in, the Google APi handles the rest
        [self closePressed:nil];
        return NO;
    } else if([[[request URL] absoluteString] hasPrefix:@"com.vocalreferences.1://"]){
        [self closePressed:nil];
        return YES;
    }
    return YES;
}
@end
