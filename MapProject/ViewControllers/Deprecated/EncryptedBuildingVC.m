//
//  EncryptedBuildingVC.m
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "EncryptedBuildingVC.h"
#import "EncryptedMapVC.h"

@interface EncryptedBuildingVC ()

@end

@implementation EncryptedBuildingVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.buildingArray = [TYBuilding parseAllBuildings:self.currentCity];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"encryptedMap"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TYBuilding *building = [self.buildingArray objectAtIndex:indexPath.row];

        EncryptedMapVC *floorMapViewController = [segue destinationViewController];
        floorMapViewController.currentCity = self.currentCity;
        floorMapViewController.currentBuilding = building;
        floorMapViewController.allMapInfos = [TYMapInfo parseAllMapInfo:building];
    }
}

@end
