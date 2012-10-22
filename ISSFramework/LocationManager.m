//
//  LocationManager.m
//  InsomniaDiary
//
//  Created by Wei Mao on 9/20/12.
//  Copyright (c) 2012 Wei Mao. All rights reserved.
//

#import "LocationManager.h"

static LocationManager *manager = nil;

@interface LocationManager()

@end

@implementation LocationManager
@synthesize delegate,lmanager;

+ (id)shareManager
{
    if (!manager) {
        manager = [[LocationManager alloc] init];
    }
    
    return manager;
}

-(void)dealloc{
    self.delegate=nil;
    self.lmanager=nil;
}

-(void)startLocalization{
    if (!lmanager) {
        lmanager = [[CLLocationManager alloc] init];
    }
    
    // 如果可以利用本地服务时
    if([CLLocationManager locationServicesEnabled]){
        // 接收事件的实例
        lmanager.delegate = self;
        // 发生事件的的最小距离间隔（缺省是不指定）
        lmanager.distanceFilter = kCLDistanceFilterNone;
        // 精度 (缺省是Best)
        lmanager.desiredAccuracy = kCLLocationAccuracyBest;
        // 开始测量 
        [lmanager startUpdatingLocation];
    }else{
        [self locationManager:lmanager didFailWithError:nil];
    }
}

// 如果GPS测量成果以下的函数被调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    // 取得经纬度
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    NSLog(@"Location Success:(%f,%f)",latitude,longitude);
    
    if (delegate) {
        [delegate location_updateLocationWithLatitude:latitude withLongitude:longitude];
    }
    [lmanager stopUpdatingLocation];
    lmanager.delegate=nil;
    lmanager=nil;
}

// 如果GPS测量失败了，下面的函数被调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"Location Failed:%@",error);
    if (delegate) {
        [delegate location_getLocationFailed:[error localizedDescription]];
    }
    [lmanager stopUpdatingLocation];
    lmanager.delegate=nil;
    lmanager=nil;
}


@end
