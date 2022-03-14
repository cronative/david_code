//
//  AppDelegate.m
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import "AppDelegate.h"
#import <Mint.h>
#import "AGSubscriptionUpdater.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AGGoogleAuth.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIApplication *app;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[Mint sharedInstance] initAndStartSession:@"58937b0b"];
    [AGSubscriptionUpdater sharedUpdater];
    [Fabric with:@[CrashlyticsKit]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openWebView:) name:ApplicationOpenGoogleAuthNotification object:nil];
    [self setApp:application];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    NSString *urlString = [NSString stringWithFormat:@"%@",url];
    NSLog(@"openURL: %@",urlString);
    if([urlString hasPrefix:@"vimeodroid://oauth.done"]){
        [[AGVimeoAuth auth] fetchAccessTokenWithRedirectedURL:url];
        return YES;
    } else if([urlString hasPrefix:@"com.vocalreferences.1:/oauth2callback2"]){
        [[AGYoutubeAuth auth] getTokensWithRedirectURL:url];
        return YES;
    } else if([urlString hasPrefix:@"com.vocalreferences.app:/oauth2callback3"]){
        return YES;
    } if([urlString hasPrefix:@"fb861886363825260"]){
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core data
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]stringByAppendingPathComponent: @"TestimonialsDB.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Orientation
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if([window.rootViewController.presentedViewController isKindOfClass:NSClassFromString(@"AVFullScreenViewController")] || _fullScreenVideoIsPlaying){
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - Google+ webView

-(void)openWebView:(NSNotification*)notific{
    NSLog(@"Need open webView with URL: %@",notific.object);
    AGGoogleAuth *auth = [[[NSBundle mainBundle] loadNibNamed:@"AGGoogleAuth" owner:self options:nil] objectAtIndex:0];
    auth.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    auth.alpha = 0;
    [_app.windows[0] addSubview:auth];
    [auth openUrl:notific.object];
}
@end
