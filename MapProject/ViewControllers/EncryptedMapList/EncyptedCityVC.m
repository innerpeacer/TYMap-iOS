//
//  EncyptedCityVC.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "EncyptedCityVC.h"
#import "BuildingTableVC.h"
#import "TYMapEnviroment.h"
#import "TYUserDefaults.h"

@interface EncyptedCityVC ()

@end

@implementation EncyptedCityVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"加密地图";
    
    [EnviromentManager switchToEncrypted];
    
    self.cityArray = [TYCity parseAllCities];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"encryptedBuildingList"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TYCity *city = [self.cityArray objectAtIndex:indexPath.row];
        
        BuildingTableVC *buildingListController = [segue destinationViewController];
        buildingListController.currentCity = city;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [EnviromentManager switchToEncrypted];
    NSLog(@"[EnviromentManager switchToEncrypted]");
}

@end
