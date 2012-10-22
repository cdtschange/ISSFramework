//
//  LocationManager.h
//  InsomniaDiary
//
//  Created by Wei Mao on 9/20/12.
//  Copyright (c) 2012 Wei Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

@required
-(void)location_updateLocationWithLatitude:(double)latitude withLongitude:(double)longitude;
-(void)location_getLocationFailed:(NSString *)error;

@end

@interface LocationManager : NSObject<CLLocationManagerDelegate>

+ (id)shareManager;

@property(strong ,nonatomic) id<LocationManagerDelegate> delegate;
@property(strong ,nonatomic) CLLocationManager *lmanager;

-(void)startLocalization;

@end
