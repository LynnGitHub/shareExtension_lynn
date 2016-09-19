//
//  LocationViewController.m
//  ShareExtension
//
//  Created by 陆永安 on 16/8/30.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController () <MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayData;

@end

@implementation LocationViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.arrayData = [NSMutableArray array];
//        添加初始model
        [self.arrayData addObject:[[LocationModel alloc] init]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"位置"];

    [self centerMapOnLocation];
    
    [self layoutTableData];
    
}


- (void)centerMapOnLocation {
    
//    显示用户位置
    self.mapView.userTrackingMode=MKUserTrackingModeFollow;
    
//    地图默认standard模式
    self.mapView.mapType=MKMapTypeStandard;
    
    self.mapView.userLocation.title = @"当前位置";
    
//    添加位置。
    MKCoordinateSpan span=MKCoordinateSpanMake(1, 1);
    MKCoordinateRegion region=MKCoordinateRegionMake(self.model.location.coordinate, span);

    [self.mapView setRegion:region];
}

- (void)layoutTableData
{
//    添加当前位置model
    [self.arrayData addObject:self.model];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    LocationModel *lModel = self.arrayData[indexPath.row];
    
    [cell.textLabel setText:lModel.address];
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    [cell.textLabel setNumberOfLines:0];
    
    if (lModel.bIsSelected)
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.arrayData enumerateObjectsUsingBlock:^(LocationModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setBIsSelected:NO];
    }];
    
    LocationModel *lModel = self.arrayData[indexPath.row];
    [lModel setBIsSelected:YES];
    
    if (self.block) {
        self.block(lModel);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData];
}

@end
