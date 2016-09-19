//
//  ShareViewController.m
//  ShareExtension
//
//  Created by 陆永安 on 16/9/5.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import "ShareViewController.h"
#import "LocationUtils.h"
#import "LocationModel.h"
#import "LocationViewController.h"

// 限制字数
static NSInteger const maxCharactersAllowed = 140;

@interface ShareViewController ()

@property (nonatomic, strong) LocationModel *tempLocationModel;

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"分享"];
}
//是否可点击
- (BOOL)isContentValid {
    
//    限制内容长度
    NSInteger length = self.contentText.length;
    
    self.charactersRemaining = @(maxCharactersAllowed - length);
    
    return (self.charactersRemaining.integerValue < 0 ? NO : (length == 0 ? NO : YES));
}
//发送按钮的Action事件
- (void)didSelectPost {
    
    __block BOOL hasExistsUrl = NO;
    __weak typeof(&*self) weakSelf =self;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"])
            {
                [weakSelf itemProvider:itemProvider
                            identifier:@"public.image"
                         extensionItem:extItem
                       bIsHasExistsUrl:hasExistsUrl
                               bIsStop:stop];
            }
            else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"])
            {
                [weakSelf itemProvider:itemProvider
                            identifier:@"public.url"
                         extensionItem:extItem
                       bIsHasExistsUrl:hasExistsUrl
                               bIsStop:stop];
            }
            
        }];
        
        if (hasExistsUrl)
        {
            *stop = YES;
        }
        
    }];
    
    if (!hasExistsUrl)
    {
        //直接退出
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }
}

//添加一些items，比如定位当下位置
- (NSArray *)configurationItems {
    SLComposeSheetConfigurationItem * oneItem = [[SLComposeSheetConfigurationItem alloc]init];
    oneItem.title = @"位置";
    oneItem.value = @"无";
    oneItem.valuePending = NO;
    __block SLComposeSheetConfigurationItem * tempOneItem = oneItem;
    __weak typeof(&*self) weakSelf = self;
    oneItem.tapHandler = ^(void)
    {
        if ([tempOneItem.value isEqualToString:@"无"])
        {
            tempOneItem.valuePending = YES;
            tempOneItem.value = @"正在定位...";
        }
        
        [LocationUtils startFetchLocationWithHandler:^(BOOL bSuccess, NSDictionary *locationDic) {
            
            if (!bSuccess) {
                tempOneItem.valuePending = NO;
                tempOneItem.value = @"定位失败";
                return ;
            }
            
            LocationModel *lModel = [[LocationModel alloc] init];
            lModel.location = [locationDic objectForKey:@"currLocation"];
            lModel.address = [locationDic objectForKey:@"address"];
            lModel.bIsSelected = YES;
            
            _tempLocationModel = lModel;
            
            tempOneItem.valuePending = NO;
            tempOneItem.value = lModel.address;
            LocationViewController * listVC = [[LocationViewController alloc] init];
            [listVC setPreferredContentSize:CGSizeMake(self.view.frame.size.width, 220)];
            [listVC setModel:lModel];
            [weakSelf pushConfigurationViewController:listVC];
            
            [listVC setBlock:^(LocationModel *lModel) {
                
                tempOneItem.value = lModel.address;
                _tempLocationModel = lModel;
            }];
            
        } bShouldRecurse:YES];
        
    };
    
    return @[oneItem];
}


#pragma mark - 调用方法
- (void)itemProvider:(NSItemProvider * _Nonnull )itemProvider
          identifier:(NSString *)identifier
       extensionItem:(NSExtensionItem * _Nonnull)extItem
     bIsHasExistsUrl:(BOOL)hasExistsUrl
             bIsStop:(BOOL * _Nonnull)stop
{
    __weak ShareViewController *theController = self;
    [itemProvider loadItemForTypeIdentifier:identifier
                                    options:nil
                          completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                              
                              if ([(NSObject *)item isKindOfClass:[NSURL class]])
                              {
                                NSLog(@"分享的%@ = %@", identifier, item);
                                NSUserDefaults *userDefaults =
                                    [[NSUserDefaults alloc]
                                        initWithSuiteName:
                                            @"group.com.ShareExtensions"];
//                                保存数据
                                NSMutableDictionary *dict = [NSMutableDictionary
                                    dictionaryWithCapacity:0];
                                [dict setValue:((NSURL *)item).absoluteString
                                        forKey:@"Enclosure"];
                                [dict setValue:theController.textView.text
                                        forKey:@"content"];
//                                [dict setValue:((SLComposeSheetConfigurationItem
//                                                     *)theController
//                                                    .configurationItems[0])
//                                                   .value
//                                        forKey:@"address"];
                                  [dict setValue:_tempLocationModel.address forKey:@"address"];

//                                转nssting
                                NSData *data = [NSJSONSerialization
                                    dataWithJSONObject:dict
                                               options:
                                                   NSJSONWritingPrettyPrinted
                                                 error:nil];
                                NSString *string = [[NSString alloc]
                                    initWithData:data
                                        encoding:NSUTF8StringEncoding];

                                [userDefaults
                                    setValue:string
                                      forKey:identifier];
//                                用于标记是新的分享
                                [userDefaults setBool:YES
                                               forKey:@"has-new-share"];

                                [theController.extensionContext
                                    completeRequestReturningItems:@[ extItem ]
                                                completionHandler:nil];
                              }
                              
                          }];
    hasExistsUrl = YES;
    *stop = YES;
}


@end
