//
//  AppDelegate.h
//  VocalReferences
//
//  Created by Andrey Golovin on 30.12.14.
//  Copyright (c) 2014 Andrey Golovin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <GooglePlus/GPPURLHandler.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) BOOL fullScreenVideoIsPlaying;

@end

