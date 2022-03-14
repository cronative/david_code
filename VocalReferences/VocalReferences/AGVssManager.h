//
//  AGVssManager.h
//  VocalReferences
//
//  Created by Andrey Golovin on 05.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const kVssDidLoadNotification;
@interface AGVssManager : NSObject

+(AGVssManager*)manager;

-(void)loadAllVss;
-(NSArray *)getAllVss;
-(NSURL*)previewUrlForVssId:(NSString *)vssId;

@end
