
//
//  BuildAllRouteNetworkVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "BuildAllRouteNetworkVC.h"

#import <TYMapData/TYMapData.h>
#import "TYMapInfo.h"
#import "TYCityManager.h"
#import "TYBuildingManager.h"
#import "RouteNDBuildingTool.h"

@interface BuildAllRouteNetworkVC() <RouteNDBuildingToolDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    NSArray *allMapInfos;
    RouteNDBuildingTool *buildingTool;

}

@end

@implementation BuildAllRouteNetworkVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(buildAllRouteNetwork) object:nil];
    [thread start];
}

- (void)buildAllRouteNetwork
{
    NSArray *cityArray = [TYCityManager parseAllCities];
    
    for (TYCity *city in cityArray) {
        currentCity = city;
        NSArray *buildingArray = [TYBuildingManager parseAllBuildings:city];
        for (TYBuilding *building in buildingArray) {
            currentBuilding = building;
            allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];

            NSDate *now = [NSDate date];
            buildingTool = [[RouteNDBuildingTool alloc] initWithBuilding:currentBuilding];
            buildingTool.delegate = self;
            [buildingTool buildRouteNetworkDataset];
            NSLog(@"Building Interval: %.2fs", [[NSDate date] timeIntervalSinceDate:now]);
            
            NSString *log = [NSString stringWithFormat:@"\tBuilding Interval: %.2fs", [[NSDate date] timeIntervalSinceDate:now]];
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];

        }
    }
    
    [self performSelectorOnMainThread:@selector(updateFinishAlert) withObject:nil waitUntilDone:YES];
}

- (void)RouteNDBuilingTool:(RouteNDBuildingTool *)tool buildingProcess:(NSString *)process
{
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:process waitUntilDone:YES];
}

- (void)updateUI:(NSString *)logString
{
    [self addToLog:logString];
}

- (void)updateFinishAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络数据集构建完成！" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
