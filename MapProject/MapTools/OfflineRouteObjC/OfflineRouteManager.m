//
//  OfflineRouteManager.m
//  MapProject
//
//  Created by innerpeacer on 15/10/10.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "OfflineRouteManager.h"
#import "RouteNetworkDataset.h"
#import "IPRoutePointConverter.h"
#import "RouteNetworkDBAdapter.h"
#import "TYMapEnviroment.h"

#define TYMapSDKRouteErrorDomain @"com.ty.mapsdk"
typedef enum {
    SolvingRouteFailed = 1000,
} RouteErrorFailed;

@interface OfflineRouteManager()
{
    RouteNetworkDataset *networkDataset;
    
    NSArray *allMapInfos;
    IPRoutePointConverter *routePointConverter;
}

@end

@implementation OfflineRouteManager

+ (OfflineRouteManager *)routeManagerWithBuilding:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    return [[OfflineRouteManager alloc] initRouteTaskWithBuilding:building MapInfos:mapInfoArray];
}

- (id)initRouteTaskWithBuilding:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    self = [super init];
    if (self) {
        allMapInfos = mapInfoArray;
        
        TYMapInfo *info = [allMapInfos objectAtIndex:0];
        routePointConverter = [[IPRoutePointConverter alloc] initWithBaseMapExtent:info.mapExtent Offset:building.offset];
        
        RouteNetworkDBAdapter *db = [[RouteNetworkDBAdapter alloc] initWithBuilding:building];
        [db open];
        networkDataset = [db readRouteNetworkDataset];
        [db close];
    }
    
    return self;
}

- (void)requestRouteWithStart:(TYLocalPoint *)start End:(TYLocalPoint *)end
{
    _startPoint = [routePointConverter routePointFromLocalPoint:start];
    _endPoint = [routePointConverter routePointFromLocalPoint:end];

    AGSPolyline *line = [networkDataset getShorestPathFrom:_startPoint To:_endPoint];
    
    BOOL solveSuccess = NO;
    TYRouteResult *result = nil;
    
    if (line && line.numPoints != 0) {
        result = [self processRouteResult:line];
        if (result) {
            solveSuccess = YES;
        }
    }
    
    if (solveSuccess) {
        if (self.delegate != nil || [self.delegate respondsToSelector:@selector(routeManager:didSolveRouteWithResult:OriginalLine:)]) {
            [self.delegate routeManager:self didSolveRouteWithResult:result OriginalLine:line];
        }
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"没有从起点到终点的路径！"                                                                     forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:TYMapSDKRouteErrorDomain code:SolvingRouteFailed userInfo:userInfo];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(routeManager:didFailSolveRouteWithError:)]) {
            [self.delegate routeManager:self didFailSolveRouteWithError:error];
        }
    }
}

- (TYRouteResult *)processRouteResult:(AGSPolyline *)routeLine
{
    NSMutableArray *pointArray = [[NSMutableArray alloc] init];
    NSMutableArray *floorArray = [[NSMutableArray alloc] init];
    
    int currentFloor = 0;
    NSMutableArray *currentArray;
    
    int pathNum = (int)routeLine.numPaths;
    if (pathNum > 0) {
        int num = (int)[routeLine numPointsInPath:0];
        for (int i = 0; i < num; ++i) {
            
            TYPoint *p = (TYPoint *)[routeLine pointOnPath:0 atIndex:i];
            TYLocalPoint *lp = [routePointConverter localPointFromRoutePoint:p];
            BOOL isValid = [routePointConverter checkPointValidity:lp];
            if (isValid) {
                
                if (lp.floor != currentFloor) {
                    currentFloor = lp.floor;
//                    NSLog(@"process currentFloor: %d", currentFloor);
                    
                    currentArray = [[NSMutableArray alloc] init];
                    [pointArray addObject:currentArray];
                    [floorArray addObject:@(currentFloor)];
                }
                [currentArray addObject:lp];
            }
        }
    }
    
    if (floorArray.count < 1) {
        return nil;
    }
    
    NSMutableArray *routePartArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < floorArray.count; ++i) {
        int floor = [floorArray[i] intValue];
        AGSMutablePolyline *line = [[AGSMutablePolyline alloc] init];
        [line addPathToPolyline];
        
        NSMutableArray *pArray = [pointArray objectAtIndex:i];
        for (int j = 0; j < pArray.count; ++j) {
            TYLocalPoint *lp = pArray[j];
            [line addPointToPath:[AGSPoint pointWithX:lp.x y:lp.y spatialReference:[TYMapEnvironment defaultSpatialReference]]];
        }
        
        TYMapInfo *info = [TYMapInfo searchMapInfoFromArray:allMapInfos Floor:floor];
        TYRoutePart *rp = [[TYRoutePart alloc] initWithRouteLine:line MapInfo:info];
        [routePartArray addObject:rp];
    }
    
    int routePartNum = (int)routePartArray.count;
    for (int i = 0; i < routePartNum; ++i) {
        
        TYRoutePart *p = routePartArray[i];
        if (i > 0) {
            p.previousPart = routePartArray[i-1];
        }
        
        if (i < routePartNum - 1) {
            p.nextPart = routePartArray[i+1];
        }
    }
    
    return [TYRouteResult routeResultWithRouteParts:routePartArray];
}

@end
