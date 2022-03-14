//
//  AGVssManager.m
//  VocalReferences
//
//  Created by Andrey Golovin on 05.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGVssManager.h"
NSString *const kVssDidLoadNotification = @"vssDidLoad";

@interface AGVssManager()

@property (nonatomic, strong) NSMutableArray *allVss;

@end

@implementation AGVssManager

+(AGVssManager*)manager{
    static AGVssManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[AGVssManager alloc] init];
        [manager loadAllVss];
    });
    return manager;
}

-(void)loadAllVss{
    AGApi *getAllVSS = [AGApi new];
    NSString *method = [NSString stringWithFormat:@"%@%@",GET_ALL_VSS,[[AGThisUser currentUser] getUserAuthToken]];
    [getAllVSS GETrequestWithMethode:method parameters:nil withAuthorization:NO success:^(id response, id wrongObject) {
        NSLog(@"Success all VSS: %@",response);
        _allVss = [NSMutableArray new];
        for(NSDictionary *dict in response[kRecords]){
            AGStorage *storage = [[AGStorage alloc] initWithDictionary:dict];
            [_allVss addObject:storage];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVssDidLoadNotification object:nil];
    } failure:^(NSError *error, NSString *errorString) {
        NSLog(@"Error all VSS: %@",error);
    }];
}
-(NSArray *)getAllVss{
    return _allVss;
}
-(NSURL*)previewUrlForVssId:(NSString *)vssId{
    for(AGStorage *vss in _allVss){
        if([vss.storageId isEqualToString:vssId]){
            NSURL *url = [NSURL URLWithString:vss.smallLogoPath];
            return url;
        }
    }
    return nil;
}

@end
