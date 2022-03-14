//
//  AGDefaultInfo.h
//  VocalReferences
//
//  Created by Andrey Golovin on 27.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGDefaultInfo : NSObject

@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSString *descript;

-(BOOL)save;
-(BOOL)remove;
@end
