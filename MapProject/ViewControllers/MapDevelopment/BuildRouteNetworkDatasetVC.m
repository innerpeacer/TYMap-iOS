//
//  BuildRouteNetworkDatasetVC.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "BuildRouteNetworkDatasetVC.h"
#import "TYUserDefaults.h"

#import "RouteNDBuildingTool.h"

@interface BuildRouteNetworkDatasetVC()
{
    RouteNDBuildingTool *buildingTool;
}

@end

@implementation BuildRouteNetworkDatasetVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    NSDate *now = [NSDate date];
    buildingTool = [[RouteNDBuildingTool alloc] initWithBuilding:self.currentBuilding];
    [buildingTool buildRouteNetworkDataset];
    NSLog(@"Build Interval For Route Network Dataset: %f", [[NSDate date] timeIntervalSinceDate:now]);
}

@end