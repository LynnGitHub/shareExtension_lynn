//
//  LocationUtils.h
//  ShareExtension
//
//  Created by 陆永安 on 16/8/31.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^locationHandler)(BOOL bSuccess, NSDictionary *locationDic);

@interface LocationUtils : NSObject


+ (void)startFetchLocationWithHandler:(locationHandler)block bShouldRecurse:(BOOL)boolValue;

@end
