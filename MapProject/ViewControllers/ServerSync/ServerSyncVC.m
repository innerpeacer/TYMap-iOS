//
//  ServerSyncVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "ServerSyncVC.h"
#import "TYBuildingManager.h"
#import "TYCityManager.h"
#import "SelectBuildingVC.h"
#import "TYUserDefaults.h"

@interface ServerSyncVC() <SelectBuildingVCDelegate>
{
    
}

@end

@implementation ServerSyncVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"地图同步";
    
    NSArray *viewControllers = @[
                                 @[@"上传所有城市建筑数据", @"UploadAllCityBuildingVC"],
                                 @[@"上传当前城市-建筑-地图信息", @"AddCityBuildingMapInfoVC"],
                                 @[@"上传地图数据", @"UploadMapDataVC"],
                                 @[@"上传路网数据", @"UploadRouteDataVC"],
                                 @[@"上传当前建筑的完整数据", @"UploadCompleteDataVC"],
                                 @[@"获取当前建筑的完整数据", @"FetchCompleteDataVC"],
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
    
//    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(choosingPlace:)];

}

- (void)SelectBuildingVC:(SelectBuildingVC *)controller didSelectBuliding:(TYBuilding *)building City:(TYCity *)city
{
    NSLog(@"MapDevVC:didSelectBuilding: %@ - %@", building.name, city.name);
    [TYUserDefaults setDefaultBuilding:building.buildingID];
    [TYUserDefaults setDefaultCity:city.cityID];
}

- (IBAction)choosingPlace:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectBuildingVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"selectBuildingController"];
    
    NSArray *cityArray = [TYCityManager parseAllCities];
    controller.cityArray = [cityArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TYCity *city1 = obj1;
        TYCity *city2 = obj2;
        return [city1.cityID caseInsensitiveCompare:city2.cityID];
    }];
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ServerSync" bundle:nil];
        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
        controller.title = key;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
