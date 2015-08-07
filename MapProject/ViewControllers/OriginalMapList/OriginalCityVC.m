//
//  OriginalCityVC.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "OriginalCityVC.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"
#import "EnviromentManager.h"
#import "BaseMapVC.h"

#import "RATreeView.h"
#import "RADataObject.h"

@interface OriginalCityVC () <CityBuildingTableVCDelegate>

@end

@implementation OriginalCityVC

- (void)viewDidLoad
{
    self.title = @"地图列表";
    [EnviromentManager switchToOriginal];

    self.cityArray = [TYCity parseAllCities];
    NSMutableArray *array = [NSMutableArray array];
    for (TYCity *city in self.cityArray) {
        NSArray *bArray = [TYBuilding parseAllBuildings:city];
        [array addObject:bArray];
    }
    self.buildingArray = [NSArray arrayWithArray:array];
    
    [super viewDidLoad];
    self.delegate = self;
}

- (void)didSelectBuilding:(TYBuilding *)building City:(TYCity *)city
{
    NSLog(@"didSelectBuilding");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BaseMapVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"originalMapContoller"];
    controller.currentBuilding = building;
    controller.currentCity = city;
    controller.allMapInfos = [TYMapInfo parseAllMapInfo:controller.currentBuilding];
    
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [EnviromentManager switchToOriginal];
    NSLog(@"[EnviromentManager switchToOriginal]");
}

@end