//
//  LocationViewController.h
//  ShareExtension
//
//  Created by 陆永安 on 16/8/30.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "LocationModel.h"

typedef void(^returnBlock)(LocationModel *model);

@interface LocationViewController : UIViewController

@property (nonatomic, strong) LocationModel *model;

@property (nonatomic, strong) returnBlock block;

@end
