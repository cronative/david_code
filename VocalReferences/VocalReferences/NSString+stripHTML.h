//
//  NSString+stripHTML.h
//  VocalReferences
//
//  Created by Andrey Golovin on 19.02.15.
//  Copyright (c) 2015 Andrey Golovin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (stripHTML)

-(NSString *) stringByStrippingHTML;
-(NSString *) stringWithoutNull;
@end
