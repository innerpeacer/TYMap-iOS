//
//  MapTableVC.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapDevVC.h"
#import "EnviromentManager.h"
#import "SelectBuildingVC.h"
#import "TYUserDefaults.h"
#import "TYBuildingManager.h"
#import "TYCityManager.h"

#define USE_ENCRYPTION_MAP 0

@interface MapDevVC() <SelectBuildingVCDelegate>
{
    
}

@end

@implementation MapDevVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if USE_ENCRYPTION_MAP
    [EnviromentManager switchToEncrypted];
#else
    [EnviromentManager switchToOriginal];
#endif
    
    
    self.title = @"地图开发";
    
    NSArray *viewControllers = @[
                                 @[@"地图 Demo", @"mapController"],
                                 //  @[@"地图导航 Demo", @"mapRouteController"],
                                 @[@"ObjC离线导航 Demo", @"OfflineMapRouteVC"],
                                 @[@"Cpp离线导航 Demo", @"CppOfflineMapRouteVC"],
                                 @[@"地图Callout Demo", @"mapCalloutController"],
                                 @[@"生成POI数据库",@"CreatePOIDatabaseVC" ],
                                 //                                 @[@"加密地图文件",@"mapEncryptionController" ],
                                 //                                 @[@"生成加密地图资源",@"GenerateEncryptionSourceVC" ],
                                 @[@"生成License", @"GenerateLicensesVC"],
                                 @[@"构建网络数据集", @"BuildRouteNetworkDatasetVC"],
                                 @[@"构建所有网络数据集",@"BuildAllRouteNetworkVC"],
                                 @[@"测试网络数据集", @"TestRouteNetworkVC"],
                                 //                                 @[@"测试Cpp网络数据集",@"TestCppRouteNetworkVC"],
                                 @[@"生成地图数据库",@"GenerateMapDBVC"],
                                 @[@"生成所有地图数据库",@"GenerateAllMapDBVC"],
                                 @[@"生成Web地图文件", @"GenerateWebMapFileVC"],
                                 @[@"生成所有Web地图文件", @"GenerateAllWebMapFileVC"],
                                 @[@"调用网络接口", @"CallingApiVC"]
                                 
                                 ];
    
    self.objects = [[NSMutableArray alloc] init];
    self.controllerDict = [[NSMutableDictionary alloc] init];
    
    
    for (int i = 0; i < viewControllers.count; ++i) {
        NSArray *controller = viewControllers[i];
        NSString *name = [NSString stringWithFormat:@"%d. %@",i+1, controller[0]];
        NSString *storyboardID = controller[1];
        [self.objects addObject:name];
        [self.controllerDict setObject:storyboardID forKey:name];
    }
    
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(choosingPlace:)];
    
    [self updateTitle];
}

- (void)updateTitle
{
    if (self.currentBuilding) {
        self.title = [NSString stringWithFormat:@"%@", self.currentBuilding.name];
    }
}

- (void)SelectBuildingVC:(SelectBuildingVC *)controller didSelectBuliding:(TYBuilding *)building City:(TYCity *)city
{
    NSLog(@"MapDevVC:didSelectBuilding: %@ - %@", building.name, city.name);
    [TYUserDefaults setDefaultBuilding:building.buildingID];
    [TYUserDefaults setDefaultCity:city.cityID];
    
    self.currentCity = city;
    self.currentBuilding = building;
    
    [self updateTitle];
    
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self updateTitle];
//    }];

}

- (IBAction)choosingPlace:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectBuildingVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"selectBuildingController"];
    
    controller.cityArray = [TYCityManager parseAllCities];
    NSMutableArray *array = [NSMutableArray array];
    for (TYCity *city in controller.cityArray) {
        NSArray *bArray = [TYBuildingManager parseAllBuildings:city];
        [array addObject:bArray];
    }
    controller.buildingArray = [NSArray arrayWithArray:array];
    controller.title = @"选择当前位置";
    controller.selectDelegate = self;
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:controller];

    [self presentViewController:naviController animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.objects objectAtIndex:indexPath.row];
    
    if ([self.controllerDict objectForKey:key] != nil) {
        NSString *identifier = [self.controllerDict objectForKey:key];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
        controller.title = key;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#if USE_ENCRYPTION_MAP
    [EnviromentManager switchToEncrypted];
//    NSLog(@"[EnviromentManager switchToEncrypted]");
#else
    [EnviromentManager switchToOriginal];
//    NSLog(@"[EnviromentManager switchToOriginal]");
#endif
}

@end
