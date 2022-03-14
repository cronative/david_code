//
//  AGDefaultInfo.m
//  VocalReferences
//
//  Created by Andrey Golovin on 27.01.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import "AGDefaultInfo.h"

static NSString *const kDefaultInfo = @"defaultInfo";

@implementation AGDefaultInfo

-(id)init{
    self = [super init];
    if(self){
        NSData *selfData = [[NSUserDefaults standardUserDefaults] objectForKey:[[AGThisUser currentUser] userEmail]];
        if(selfData){
            self = [NSKeyedUnarchiver unarchiveObjectWithData:selfData];
        }
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        _companyName = [aDecoder decodeObjectForKey:@"companyName"];
        _phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
        _website = [aDecoder decodeObjectForKey:@"website"];
        _keywords = [aDecoder decodeObjectForKey:@"keywords"];
        _descript = [aDecoder decodeObjectForKey:@"descript"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_companyName forKey:@"companyName"];
    [aCoder encodeObject:_phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeObject:_website forKey:@"website"];
    [aCoder encodeObject:_keywords forKey:@"keywords"];
    [aCoder encodeObject:_descript forKey:@"descript"];
}

-(BOOL)save{
    NSData *selfData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:selfData forKey:[[AGThisUser currentUser] userEmail]];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)remove{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[[AGThisUser currentUser] userEmail]];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
