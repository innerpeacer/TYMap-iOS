//
//  BuildRouteNetworkDatasetVC.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "BuildRouteNetworkDatasetVC.h"
#import "TYUserDefaults.h"

#import "TYMapEnviroment.h"
#import "RouteNDBuildingTool.h"

@interface BuildRouteNetworkDatasetVC()<RouteNDBuildingToolDelegate>
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
    
    [self zoomToAllExtent];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(buildRouteNetwork) object:nil];
    [thread start];
}

- (void)buildRouteNetwork
{
    NSDate *now = [NSDate date];
    buildingTool = [[RouteNDBuildingTool alloc] initWithBuilding:self.currentBuilding];
    buildingTool.delegate = self;
    [buildingTool buildRouteNetworkDataset];
    NSLog(@"Build Interval For Route Network Dataset: %f", [[NSDate date] timeIntervalSinceDate:now]);
}

- (void)RouteNDBuilingTool:(RouteNDBuildingTool *)tool buildingProcess:(NSString *)process
{
    NSLog(@"%@", process);
}

- (void)zoomToAllExtent
{
    int maxFloor = 1;
    int minFloor = 1;
    TYMapInfo *firstInfo = [self.allMapInfos objectAtIndex:0];
    double xmax = firstInfo.mapExtent.xmax;
    double xmin = firstInfo.mapExtent.xmin;
    double ymax = firstInfo.mapExtent.ymax;
    double ymin = firstInfo.mapExtent.ymin;
    for (TYMapInfo *info in self.allMapInfos) {
        if (info.floorNumber > maxFloor) {
            maxFloor = info.floorNumber;
            xmax = info.mapExtent.xmax + (maxFloor - 1) * self.currentBuilding.offset.x;
        }
        
        if (info.floorNumber < minFloor) {
            minFloor = info.floorNumber;
            xmin = info.mapExtent.xmin + (minFloor - 1) * self.currentBuilding.offset.x;
        }
    }
    
    AGSEnvelope *routeEnvelop = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:[TYMapEnvironment defaultSpatialReference]];
    NSLog(@"%@", routeEnvelop);
    [self.mapView zoomToEnvelope:routeEnvelop animated:YES];
}


@end