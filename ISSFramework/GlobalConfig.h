//
//  GlobalConfig.h
//  CdtsFramework
//
//  Created by 山天 大畜 on 6/07/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//
#ifndef ISS_GLOBAL_CONFIG
#define ISS_GLOBAL_CONFIG

#ifdef ISS_DEBUG
#define UADebugLog( s, ... ) NSLog( @"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define UADebugLog( s, ... ) 
#endif


#endif