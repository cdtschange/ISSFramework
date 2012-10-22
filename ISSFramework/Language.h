//
//  Language.h
//  CdtsFramework
//
//  Created by 山天 大畜 on 4/05/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Language : NSObject

+(void)initialize;
+(void)setLanguage:(NSString *)language ;
+(NSString *)getLanguage;
+(NSString *)get:(NSString *)key alter:(NSString *)alternate ;

@end
