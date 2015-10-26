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
    
    self.objects = [[NSMutableArray alloc] init];
    self.controllerDict = [[NSMutableDictionary alloc] init];
    
    self.title = @"地图开发";
    
    [self.objects addObject:@"地图 Demo"];
    [self.controllerDict setObject:@"mapController" forKey:@"地图 Demo"];
    
//    [self.objects addObject:@"地图导航 Demo"];
//    [self.controllerDict setObject:@"mapRouteController" forKey:@"地图导航 Demo"];
    
    [self.objects addObject:@"ObjC离线导航 Demo"];
    [self.controllerDict setObject:@"OfflineMapRouteVC" forKey:@"ObjC离线导航 Demo"];
    
    [self.objects addObject:@"Cpp离线导航 Demo"];
    [self.controllerDict setObject:@"CppOfflineMapRouteVC" forKey:@"Cpp离线导航 Demo"];
    
    [self.objects addObject:@"地图Callout Demo"];
    [self.controllerDict setObject:@"mapCalloutController" forKey:@"地图Callout Demo"];
    
    [self.objects addObject:@"生成POI数据库"];
    [self.controllerDict setObject:@"CreatePOIDatabaseVC" forKey:@"生成POI数据库"];
 
    [self.objects addObject:@"加密地图文件"];
    [self.controllerDict setObject:@"mapEncryptionController" forKey:@"加密地图文件"];
    
    [self.objects addObject:@"生成加密地图资源"];
    [self.controllerDict setObject:@"GenerateEncryptionSourceVC" forKey:@"生成加密地图资源"];
    
    [self.objects addObject:@"生成License"];
    [self.controllerDict setObject:@"GenerateLicensesVC" forKey:@"生成License"];
    
    [self.objects addObject:@"构建网络数据集"];
    [self.controllerDict setObject:@"BuildRouteNetworkDatasetVC" forKey:@"构建网络数据集"];
    
    [self.objects addObject:@"测试网络数据集"];
    [self.controllerDict setObject:@"TestRouteNetworkVC" forKey:@"测试网络数据集"];
    
//    [self.objects addObject:@"测试Cpp网络数据集"];
//    [self.controllerDict setObject:@"TestCppRouteNetworkVC" forKey:@"测试Cpp网络数据集"];
    
    [self.objects addObject:@"生成地图数据库"];
    [self.controllerDict setObject:@"GenerateMapDBVC" forKey:@"生成地图数据库"];
    
    [self.objects addObject:@"生成所有地图数据库"];
    [self.controllerDict setObject:@"GenerateAllMapDBVC" forKey:@"生成所有地图数据库"];
    
//    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(choosingPlace:)];
    
    [self updateTitle];
}

- (void)updateTitle
{
    if (self.currentBuilding) {
        self.title = [NSString stringWithFormat:@"%@", self.currentBuilding.name];
    }
}

//- (void)didSelectBuilding:(TYBuilding *)building City:(TYCity *)city
//{
//    NSLog(@"Hello: didSelectBuilding: %@ - %@", building.name, city.name);
//    [TYUserDefaults setDefaultBuilding:building.buildingID];
//    [TYUserDefaults setDefaultCity:city.cityID];
//    
//    self.currentCity = city;
//    self.currentBuilding = building;
//    
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self updateTitle];
//    }];
//}

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
