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
    if (networkDataset) {
        delete networkDataset;
    }
}

- (void)requestRouteWithStart:(TYLocalPoint *)start End:(TYLocalPoint *)end
{
    GeometryFactory factory;
    
    _startPoint = [routePointConverter routePointFromLocalPoint:start];
    _endPoint = [routePointConverter routePointFromLocalPoint:end];
    
    Coordinate startCoord;
    startCoord.x = _startPoint.x;
    startCoord.y = _startPoint.y;
    
    Coordinate endCoord;
    endCoord.x = _endPoint.x;
    endCoord.y = _endPoint.y;
    
    geos::geom::Point *gStart = factory.createPoint(startCoord);
    geos::geom::Point *gEnd = factory.createPoint(endCoord);
    
    LineString *line = networkDataset->getShorestPath(gStart, gEnd);
    
    delete gStart;
    delete gEnd;
    
    BOOL solveSuccess = NO;
    
    AGSPolyline *polyline;
    TYRouteResult *result = nil;
    
    if (line != NULL && line->getNumPoints() != 0) {
        polyline = [self convertLineString:line];
        result = [self processAgsPolyline:polyline];
        if (result) {
            solveSuccess = YES;
        }
    }
    delete line;
    
    if (solveSuccess) {
        if (self.delegate != nil || [self.delegate respondsToSelector:@selector(offlineRouteManager:didSolveRouteWithResult:)]) {
            [self.delegate offlineRouteManager:self didSolveRouteWithResult:result];
        }
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"没有从起点到终点的路径！"                                                                     forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:TYMapSDKOfflineRouteErrorDomain code:TYSolvingRouteFailed userInfo:userInfo];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(offlineRouteManager:didFailSolveRouteWithError:)]) {
            [self.delegate offlineRouteManager:self didFailSolveRouteWithError:error];
        }
    }


}

//- (TYRouteResult *)processRouteResult:(geos::geom::LineString *)routeLine
//{
//    AGSPolyline *line = [self convertLineString:routeLine];
//    return [self processAgsPolyline:line];
//}

- (AGSPolyline *)convertLineString:(geos::geom::LineString *)line
{
    AGSMutablePolyline *resultLine = [[AGSMutablePolyline alloc] init];
    [resultLine addPathToPolyline];
    
    for(int i = 0; i < line->getNumPoints(); ++i)
    {
        Coordinate c = line->getCoordinateN(i);
        [resultLine addPointToPath:[AGSPoint pointWithX:c.x y:c.y spatialReference:[TYMapEnvironment defaultSpatialReference]]];
    }
    return resultLine;
}

- (TYRouteResult *)processAgsPolyline:(AGSPolyline *)routeLine
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
        p.partIndex = i;
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
