//
//  Language.m
//  CdtsFramework
//
//  Created by 山天 大畜 on 4/05/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "Language.h"

@implementation Language

static NSBundle *bundle = nil;
static NSString *language = nil;

+(void)initialize {
    NSString *current = [self getLanguage];
    [self setLanguage:current];
    
}

/*
 example calls:
 [Language setLanguage:@"it"];
 [Language setLanguage:@"de"];
 */
+(void)setLanguage:(NSString *)_language {
    NSLog(@"preferredLang: %@", _language);
    language=_language;
    NSString *path = [[ NSBundle mainBundle ] pathForResource:language ofType:@"lproj" ];
    bundle = [NSBundle bundleWithPath:path];
}
+(NSString *)getLanguage{
    if (!language) {
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        NSArray* languages = [defs objectForKey:@"AppleLanguages"];
        NSString *current = [languages objectAtIndex:0];
        NSLog(@"getLang: %@", current);
        language=current;
    }
    return language;
}

+(NSString *)get:(NSString *)key alter:(NSString *)alternate {
    return [bundle localizedStringForKey:key value:alternate table:nil];
}

@end
