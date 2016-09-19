//
//  LocationModel.m
//  ShareExtension
//
//  Created by 陆永安 on 16/8/31.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import "LocationModel.h"

@implementation LocationModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.address = @"无";
        self.bIsSelected = NO;
        self.location = nil;
    }
    return self;
}

@end
