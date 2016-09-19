//
//  LocationUtils.m
//  ShareExtension
//
//  Created by 陆永安 on 16/8/31.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import "LocationUtils.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationUtils () <CLLocationManagerDelegate>

@property (strong ,nonatomic) CLLocationManager *locationManager;

//定位成功或者失败回调
@property (copy, nonatomic) locationHandler compeleteHandler;

//是否跟新当前位置
@property (assign, nonatomic) BOOL bLocated;

@end

@implementation LocationUtils

+ (LocationUtils *)sharedManager {
    static LocationUtils *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDistanceFilter:kCLLocationAccuracyBest];
    }
    return _locationManager;
}

+ (void)startFetchLocationWithHandler:(locationHandler)block bShouldRecurse:(BOOL)boolValue
{
    [[self sharedManager] startFetchLocationWithHandler:block bShouldRecurse:boolValue];
}

- (void)startFetchLocationWithHandler:(locationHandler)block bShouldRecurse:(BOOL)boolValue
{
    self.bLocated = boolValue;
    self.compeleteHandler = block;
    
    [self startLocation];
}

/**
 *  @author liyong
 *
 *  单纯定位
 */
- (void)startLocation
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        if ([CLLocationManager locationServicesEnabled])
        {
            [self.locationManager requestWhenInUseAuthorization]; //使用中授权
            [self.locationManager startUpdatingLocation];
            self.locationManager.delegate = self;
        }
        else
        {
            //定位功能不可使用
            if (self.compeleteHandler != nil)
            {
                self.compeleteHandler(NO, nil);
            }
        }
    }
}

- (void)recursionLocate
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
        {
            if (!self.bLocated)
            {
                [_locationManager setDelegate:self];
                [_locationManager startUpdatingLocation];
                [self recursionLocate];
            }
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.bLocated = YES;
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];
    
    if ([locations count] != 0)
    {
        CLLocation *newLocation = [locations objectAtIndex:0];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error){
            if ([placemarks count] <= 0)
            {
                if (self.compeleteHandler != nil)
                {
                    self.compeleteHandler(NO, nil);
                }
                
                return;
            }
            
            for (CLPlacemark *placemark in placemarks)
            {
                NSDictionary *addrDict = [placemark addressDictionary];
                
                //获取定位的经纬度
                CLLocation *currLocation = [[locations lastObject] isEqual:[NSNull null]] ? nil : [locations lastObject];
                
                //获取定位的省份
                NSString *stateStr = [self isBlankReqString:[addrDict objectForKey:@"State"]] ? @"" : [addrDict objectForKey:@"State"];
                
                //获取定位的城市
                NSString *city = [self isBlankReqString:[addrDict objectForKey:@"City"]] ? @"" : [addrDict objectForKey:@"City"];
                
                //获取定位的subLocality
                NSString *subLocalityStr = [self isBlankReqString:[addrDict objectForKey:@"SubLocality"]] ? @"" : [addrDict objectForKey:@"SubLocality"];
                
                //获取定位的街道
                NSString *streetStr = [self isBlankReqString:[addrDict objectForKey:@"Street"]] ? @"" : [addrDict objectForKey:@"Street"];
                
                NSString *address = nil;
                NSDictionary *locationDic;
                
                if ([[[addrDict objectForKey:@"FormattedAddressLines"] class] isSubclassOfClass:NSClassFromString(@"NSArray")])
                {
                    NSArray *addrArr = [addrDict objectForKey:@"FormattedAddressLines"];
                    
                    NSString *tempAddress = [NSString stringWithFormat:@"%@%@%@"
                                         ,city
                                         ,subLocalityStr
                                         ,[streetStr isEqualToString:subLocalityStr] ? @"" : streetStr];
                    
                    address = [addrArr count] > 0 ? [addrArr firstObject] : tempAddress;

                    locationDic = @{@"address" : address,
                                    @"currLocation" : currLocation};
                    
                    if (self.compeleteHandler != nil)
                    {
                        self.compeleteHandler(addrArr ? YES:NO, locationDic);
                    }
                }
                else if ([[[addrDict objectForKey:@"FormattedAddressLines"] class] isSubclassOfClass:NSClassFromString(@"NSString")])
                {
                    
                    NSString *tempAddress = [NSString stringWithFormat:@"%@%@%@%@"
                                         ,stateStr
                                         ,city
                                         ,subLocalityStr
                                         ,[streetStr isEqualToString:subLocalityStr] ? @"" : streetStr];
                    
                    address = ([[addrDict objectForKey:@"FormattedAddressLines"] isEqual:[NSNull null]] ? tempAddress : [addrDict objectForKey:@"FormattedAddressLines"]);
                    
                    address = address.length > 0 ? address : tempAddress;
                    
                    locationDic = @{@"address" : address,
                                    @"currLocation" : currLocation};
                    
                    if (self.compeleteHandler != nil)
                    {
                        self.compeleteHandler(YES, locationDic);
                    }
                }
            }
        }];
    }
}

/**
 *  判断当前字符串有没有为空
 *
 *  @return bool yes代表有，no代表没有
 */
- (BOOL)isBlankReqString:(NSString *)str
{
    if (str == nil){
        return YES;
    }
    if (str == NULL){
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]){
        return YES;
    }
    return NO;
}


@end
