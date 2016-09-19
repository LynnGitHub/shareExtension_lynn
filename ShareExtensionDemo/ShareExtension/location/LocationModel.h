//
//  LocationModel.h
//  ShareExtension
//
//  Created by 陆永安 on 16/8/31.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationModel : NSObject

@property (nonatomic, strong) NSString *address;

@property (nonatomic, assign) BOOL bIsSelected;

@property (nonatomic, strong) CLLocation *location;

@end
