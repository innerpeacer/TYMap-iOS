//
//  TYOfflineRouteManager.m
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYOfflineRouteManager.h"

#import "TYRoutePointConverter.h"
#import "TYMapEnviroment.h"

#import "IPXRouteNetworkDataset.hpp"
#import "IPXRouteNetworkDBAdapter.hpp"

using namespace Innerpeacer::MapSDK;
using namespace std;

#define TYMapSDKOfflineRouteErrorDomain @"com.ty.mapsdk"
typedef enum {
    TYSolvingRouteFailed = 1000,
} TYRouteErrorFailed;


@interface TYOfflineRouteManager()
{
    IPXRouteNetworkDataset *networkDataset;
    
    NSArray *allMapInfos;
    TYRoutePointConverter *routePointConverter;
}

@end

@implementation TYOfflineRouteManager

+ (TYOfflineRouteManager *)routeManagerWithBuilding:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    return [[TYOfflineRouteManager alloc] initRouteManagerWithBuilding:building MapInfos:mapInfoArray];
}

- (id)initRouteManagerWithBuilding:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    self = [super init];
    if (self) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        allMapInfos = mapInfoArray;
        
        TYMapInfo *info = [allMapInfos objectAtIndex:0];
        routePointConverter = [[TYRoutePointConverter alloc] initWithBaseMapExtent:info.mapExtent Offset:building.offset];
        
        NSString *dbPath = [self getRouteDBPath:building];
        IPXRouteNetworkDBAdapter *db = new IPXRouteNetworkDBAdapter([dbPath UTF8String]);
        db->open();
        networkDataset = db->readRouteNetworkDataset();
        
        cout << networkDataset->toString() << endl;
        
        db->close();
        delete db;

        
    }
    return self;
}

- (NSString *)getRouteDBPath:(TYBuilding *)building
{
    NSString *dbName = [NSString stringWithFormat:@"%@_Route.db", building.buildingID];
    return [[TYMapEnvironment getBuildingDirectory:building] stringByAppendingPathComponent:dbName];
}

- (void)dealloc
{
    
}

- (void)requestRouteWithStart:(TYLocalPoint *)start End:(TYLocalPoint *)end
{
    
}

@end
