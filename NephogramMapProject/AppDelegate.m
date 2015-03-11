//
//  AppDelegate.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "AppDelegate.h"
#import "NPUserDefaults.h"

#import "NPMapEnviroment.h"
#import "NPPoi.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    [NPMapEnvironment initMapEnvironment];
    
    [self setDefaultPlaceIfNeeded];
    
    [self test];
    
    return YES;
}

- (void)setDefaultPlaceIfNeeded
{
    NSString *defaultCityID = [NPUserDefaults getDefaultCity];
    if (defaultCityID == nil) {
        [NPUserDefaults setDefaultCity:@"0021"];
    }
    
    NSString *defaultBuildingID = [NPUserDefaults getDefaultBuilding];
    if (defaultBuildingID == nil) {
        [NPUserDefaults setDefaultBuilding:@"00210003"];
    }
    
    [NPUserDefaults setDefaultCity:@"0021"];
    [NPUserDefaults setDefaultBuilding:@"002100001"];
    [NPUserDefaults setDefaultBuilding:@"002100002"];
//    [NPUserDefaults setDefaultBuilding:@"002100004"];
//    [NPUserDefaults setDefaultBuilding:@"002199999"];
    
}

- (void)test
{
//    NSLog(@"Room Type: %d", POI_ROOM);
//    NSLog(@"Asset Type: %d", POI_ASSET);
//    NSLog(@"Facility Type: %d", POI_FACILITY);

    
//    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
//    
//    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] init];
//    [polygon addRingToPolygon];
//    [polygon addPointToRing:[AGSPoint pointWithX:0 y:0 spatialReference:[NPMapEnvironment defaultSpatialReference]]];
//    [polygon addPointToRing:[AGSPoint pointWithX:0 y:1 spatialReference:[NPMapEnvironment defaultSpatialReference]]];
//    [polygon addPointToRing:[AGSPoint pointWithX:1 y:1 spatialReference:[NPMapEnvironment defaultSpatialReference]]];
//    [polygon addPointToRing:[AGSPoint pointWithX:1 y:0 spatialReference:[NPMapEnvironment defaultSpatialReference]]];
//    [polygon addPointToRing:[AGSPoint pointWithX:0 y:0 spatialReference:[NPMapEnvironment defaultSpatialReference]]];
//
//    AGSMutablePoint *mp = [engine labelPointForPolygon:polygon];
//    NSLog(@"%@", mp);
}

@end

