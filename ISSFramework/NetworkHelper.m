//
//  NetworkManager.m
//  InsomniaDiary
//
//  Created by Wei Mao on 9/27/12.
//  Copyright (c) 2012 Wei Mao. All rights reserved.
//

#import "NetworkHelper.h"
#import "Reachability.h"

static NetworkHelper *manager = nil;

@implementation NetworkHelper
@synthesize httpRequest;
@synthesize delegate;
@synthesize reachUrl;

+ (id)shareManager
{
    if (!manager) {
        manager = [[NetworkHelper alloc] init];
    }
    
    return manager;
}

-(id)init{
    if (self = [super init]) {
        // Initialization code
        self.reachUrl=@"www.baidu.com";
    }
    return self;
}

+ (BOOL)isNetworkReachable
{
	return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

-(void)listenNetwork{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    Reachability *hostReach = [Reachability reachabilityWithHostname:self.reachUrl];//可以以多种形式初始化
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: hostReach];
}

// 连接改变
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

//处理连接改变后的情况
- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [curReach currentReachabilityStatus];
    NSLog(@"NetworkStatus:%d",status);
    switch (status) {
		case NotReachable:
            if (delegate) {
                [delegate network_NotReachable];
            }
			NSLog(@"当前网络不可用");
			break;
		case ReachableViaWWAN:
            if (delegate) {
                [delegate network_ReachableViaWWAN];
            }
			//NSLog(@"使用3G网络");
			break;
		case ReachableViaWiFi:
            if (delegate) {
                [delegate network_ReachableViaWiFi];
            }
			//NSLog(@"使用WiFi网络");
			break;
    }
}



- (ASIHTTPRequest *)httpRequest
{
    return httpRequest;
}

-(void)dealloc{
    self.httpRequest=nil;
}

@end
