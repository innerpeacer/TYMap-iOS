//
//  OriginalCityVC.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "OriginalCityVC.h"
#import "BuildingTableVC.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"

@interface OriginalCityVC ()

@end

@implementation OriginalCityVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"地图列表";

    [EnviromentManager switchToOriginal];

    self.cityArray = [TYCity parseAllCities];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"originalBuildingList"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TYCity *city = [self.cityArray objectAtIndex:indexPath.row];
        
        BuildingTableVC *buildingListController = [segue destinationViewController];
        buildingListController.currentCity = city;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [EnviromentManager switchToOriginal];
    NSLog(@"[EnviromentManager switchToOriginal]");
}


@end