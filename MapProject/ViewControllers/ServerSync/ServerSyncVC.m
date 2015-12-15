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
                                 @[@"上传当前建筑的完整数据", @"UploadCompleteDataVC"],

                                 
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
