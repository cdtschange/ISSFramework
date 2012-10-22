//
//  NetworkManager.h
//  InsomniaDiary
//
//  Created by Wei Mao on 9/27/12.
//  Copyright (c) 2012 Wei Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@protocol NetworkDelegate <NSObject>

@optional
-(void) network_NotReachable;
-(void) network_ReachableViaWWAN;
-(void) network_ReachableViaWiFi;

@end

@interface NetworkHelper : NSObject

+ (id)shareManager;

@property (strong, nonatomic) ASIHTTPRequest *httpRequest;
@property (assign,nonatomic) id<NetworkDelegate> delegate;
@property (strong,nonatomic) NSString *reachUrl;

-(void) listenNetwork;

+ (BOOL)isNetworkReachable;

@end
