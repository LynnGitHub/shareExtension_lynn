//
//  ViewController.m
//  ShareExtensionDemo
//
//  Created by 陆永安 on 16/9/5.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UILabel *address;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _content.layer.shadowOffset = CGSizeMake(0, 2);
    _content.layer.shadowOpacity = 0.5;
    
    _address.layer.shadowOffset = CGSizeMake(0, 2);
    _address.layer.shadowOpacity = 0.5;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fun:)
                                                 name:@"share-public-notification"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"share-public-notification" object:nil];
}

- (void)fun:(NSNotification *)notification
{
    NSLog(@"userInfo>>>>%@",notification.userInfo);
    
    NSURL *url=[NSURL URLWithString:[notification.userInfo objectForKey:@"Enclosure"]];
    UIImage *imgFromUrl =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
    [_imgView setImage:imgFromUrl];
    [_content setText:[notification.userInfo objectForKey:@"content"]];
    [_address setText:[notification.userInfo objectForKey:@"address"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
