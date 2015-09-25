//
//  EncyptedCityVC.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "EncyptedCityVC.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"
#import "EnviromentManager.h"
#import "BaseMapVC.h"

#import "RATreeView.h"
#import "RADataObject.h"

#import "TYCityManager.h"
#import "TYBuildingManager.h"

@interface EncyptedCityVC () <CityBuildingTableVCDelegate>

@end


@implementation EncyptedCityVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"加密地图";
    [EnviromentManager switchToEncrypted];
    self.delegate = self;
}

- (void)loadMapContent
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:DEFAULT_MAP_ENCRPTION_ROOT]]) {
        self.cityArray = [TYCityManager parseAllCities];
        NSMutableArray *array = [NSMutableArray array];
        for (TYCity *city in self.cityArray) {
            NSArray *bArray = [TYBuildingManager parseAllBuildings:city];
            [array addObject:bArray];
        }
        self.buildingArray = [NSArray arrayWithArray:array];
    }
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
    [EnviromentManager switchToEncrypted];
    NSLog(@"[EnviromentManager switchToEncrypted]");
    
    [self loadMapContent];
    [self reloadData];
}

@end