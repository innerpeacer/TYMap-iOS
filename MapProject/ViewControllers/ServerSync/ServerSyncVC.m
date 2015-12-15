//
//  ServerSyncVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "ServerSyncVC.h"

@interface ServerSyncVC()
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
//                                 @[@"生成POI数据库",@"CreatePOIDatabaseVC" ],
//                                 //                                 @[@"加密地图文件",@"mapEncryptionController" ],
//                                 //                                 @[@"生成加密地图资源",@"GenerateEncryptionSourceVC" ],
//                                 @[@"生成License", @"GenerateLicensesVC"],
//                                 @[@"构建网络数据集", @"BuildRouteNetworkDatasetVC"],
//                                 @[@"构建所有网络数据集",@"BuildAllRouteNetworkVC"],
//                                 @[@"测试网络数据集", @"TestRouteNetworkVC"],
//                                 //                                 @[@"测试Cpp网络数据集",@"TestCppRouteNetworkVC"],
//                                 @[@"生成地图数据库",@"GenerateMapDBVC"],
//                                 @[@"生成所有地图数据库",@"GenerateAllMapDBVC"],
//                                 @[@"生成Web地图文件", @"GenerateWebMapFileVC"],
//                                 @[@"生成所有Web地图文件", @"GenerateAllWebMapFileVC"],
//                                 @[@"调用网络接口", @"CallingApiVC"]
                                 
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
    
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
