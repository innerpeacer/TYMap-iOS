//
//  NPRouteManager.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteManager.h"
#import "NPRoutePointConverter.h"
#import "NPBuilding.h"
#import "NPRoutePart.h"

@interface NPRouteManager() <AGSRouteTaskDelegate>
{
    AGSRouteTask *routeTask;
    AGSRouteTaskParameters *routeTaskParams;
    NPCredential *credential;

    NSArray *allMapInfos;
    
    NPRoutePointConverter *routePointConverter;
}

@end

@implementation NPRouteManager


+ (NPRouteManager *)routeManagerWithBuilding:(NPBuilding *)building credential:(NPCredential *)credential MapInfos:(NSArray *)mapInfoArray
{
    return [[NPRouteManager alloc] initRouteTaskWithBuilding:building credential:credential MapInfos:mapInfoArray];
}

- (id)initRouteTaskWithBuilding:(NPBuilding *)building credential:(NPCredential *)cr  MapInfos:(NSArray *)mapInfoArray
{
    self = [super init];
    if (self) {
        credential = cr;
        allMapInfos = mapInfoArray;
        
        NPMapInfo *info = [allMapInfos objectAtIndex:0];
        routePointConverter = [[NPRoutePointConverter alloc] initWithBaseMapExtent:info.mapExtent Offset:building.offset];
        
        NSURL *url = [NSURL URLWithString:building.routeURL];
        routeTask = [AGSRouteTask routeTaskWithURL:url credential:cr];
        routeTask.delegate = self;
        [routeTask retrieveDefaultRouteTaskParameters];
    }
    
    return self;
}

- (void)requestRouteWithStart:(NPLocalPoint *)start End:(NPLocalPoint *)end
{
    NSMutableArray *stops = [NSMutableArray array];
    
    _startPoint = [routePointConverter routePointFromLocalPoint:start];
    _endPoint = [routePointConverter routePointFromLocalPoint:end];
    
    [stops addObject:[AGSGraphic graphicWithGeometry:_startPoint symbol:nil attributes:nil]];
    [stops addObject:[AGSGraphic graphicWithGeometry:_endPoint symbol:nil attributes:nil]];
    
    [routeTaskParams setStopsWithFeatures:stops];
    
    routeTaskParams.outputGeometryPrecision = 0.1;
    routeTaskParams.outputGeometryPrecisionUnits = AGSUnitsMeters;
    
    routeTaskParams.returnRouteGraphics = YES;
    routeTaskParams.returnDirections = YES;
    
    routeTaskParams.findBestSequence = YES;
    routeTaskParams.preserveFirstStop = YES;
    routeTaskParams.preserveLastStop = YES;
    
    routeTaskParams.returnStopGraphics = YES;
    routeTaskParams.outSpatialReference = [NPMapEnvironment defaultSpatialReference];
    
    routeTaskParams.ignoreInvalidLocations = YES;
    
    [routeTask solveWithParameters:routeTaskParams];
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error
{
//    NSLog(@"didFailSolveWithError:\n%@", error.localizedDescription);
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(routeManager:didFailSolveRouteWithError:)]) {
        [self.delegate routeManager:self didFailSolveRouteWithError:error];
    }
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult
{
//    NSLog(@"didSolveWithResult");
    
    AGSRouteResult *routeResult = [routeTaskResult.routeResults firstObject];
    
    if (routeResult) {
        
        NPRouteResult *result = [self processRouteResult:routeResult];
        
        NSArray *array = [self processRouteResultV2:routeResult];
        NSLog(@"%d parts", (int)array.count);
        for (NPRoutePart *rp in array) {
            NSLog(@"%@", rp);
        }
        
        if (result == nil) {
            return;
        }
        
        if (self.delegate != nil || [self.delegate respondsToSelector:@selector(routeManager:didSolveRouteWithResult:)]) {
            [self.delegate routeManager:self didSolveRouteWithResult:result];
        }
    }
}

- (NPRouteResult *)processRouteResult:(AGSRouteResult *)rs
{
    NSMutableDictionary *pointDict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *floorArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *routeDict = [[NSMutableDictionary alloc] init];
    
    AGSPolyline *routeLine = (AGSPolyline *)rs.routeGraphic.geometry;
    
    int pathNum = (int)routeLine.numPaths;
    if (pathNum > 0) {
        
        int num = (int)[routeLine numPointsInPath:0];
        
        for (int i = 0; i < num; ++i) {
            NPPoint *p = (NPPoint *)[routeLine pointOnPath:0 atIndex:i];
            
            NPLocalPoint *lp = [routePointConverter localPointFromRoutePoint:p];
            BOOL isValid = [routePointConverter checkPointValidity:lp];
            if (isValid) {
                if (![pointDict.allKeys containsObject:@(lp.floor)]) {
                    [pointDict setObject:[NSMutableArray array] forKey:@(lp.floor)];
                    [floorArray addObject:@(lp.floor)];
                }
                NSMutableArray *array = [pointDict objectForKey:@(lp.floor)];
                [array addObject:lp];
            }
        }
    }
    
    for (NSNumber *f in floorArray) {
        NSMutableArray *array = [pointDict objectForKey:f];
        
        AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] initWithSpatialReference:[NPMapEnvironment defaultSpatialReference]];
        [polyline addPathToPolyline];
        
        for (NPLocalPoint *lp in array) {
            [polyline addPointToPath:[AGSPoint pointWithX:lp.x y:lp.y spatialReference:[NPMapEnvironment defaultSpatialReference]]];
        }
        [routeDict setObject:polyline forKey:f];
    }
    
    if (routeDict.count < 1) {
        return nil;
    }
    
    return [NPRouteResult routeResultWithDict:routeDict FloorArray:floorArray];
}

- (NSArray *)processRouteResultV2:(AGSRouteResult *)rs
{
    NSMutableArray *pointArray = [[NSMutableArray alloc] init];
    NSMutableArray *floorArray = [[NSMutableArray alloc] init];
    
    AGSPolyline *routeLine = (AGSPolyline *)rs.routeGraphic.geometry;
    
    int currentFloor = 0;
    NSMutableArray *currentArray;
    
    int pathNum = (int)routeLine.numPaths;
    if (pathNum > 0) {
        int num = (int)[routeLine numPointsInPath:0];
        for (int i = 0; i < num; ++i) {
            
            NPPoint *p = (NPPoint *)[routeLine pointOnPath:0 atIndex:i];
            NPLocalPoint *lp = [routePointConverter localPointFromRoutePoint:p];
            BOOL isValid = [routePointConverter checkPointValidity:lp];
            if (isValid) {
                
                if (lp.floor != currentFloor) {
                    currentFloor = lp.floor;
                    currentArray = [[NSMutableArray alloc] init];
                    [pointArray addObject:currentArray];
                    [floorArray addObject:@(currentFloor)];
                }
                [currentArray addObject:p];
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
            [line addPointToPath:pArray[i]];
        }
        
        NPMapInfo *info = [NPMapInfo searchMapInfoFromArray:allMapInfos Floor:floor];
//        NPRoutePart *rp = [[NPRoutePart alloc] initWithRouteLine:line Floor:floor];
        NPRoutePart *rp = [[NPRoutePart alloc] initWithRouteLine:line MapInfo:info];
        [routePartArray addObject:rp];
    }
    
    int routePartNum = (int)routePartArray.count;
    for (int i = 0; i < routePartNum; ++i) {
        
        NPRoutePart *p = routePartArray[i];
        if (i > 0) {
            p.previousPart = routePartArray[i-1];
        }
        
        if (i < routePartNum - 1) {
            p.nextPart = routePartArray[i+1];
        }
        
//        if (i == 0) {
//            NPRoutePart *p0 = routePartArray[i];
//            p0.previousPart = nil;
//            p0.nextPart = routePartArray[i+1];
//        } else if (i == routePartNum - 1) {
//            NPRoutePart *p1 = routePartArray[i];
//            p1.nextPart = nil;
//            p1.previousPart = routePartArray[i-1];
//        } else {
//            NPRoutePart *p = routePartArray[i];
//            p.previousPart = routePartArray[i-1];
//            p.nextPart = routePartArray[i+1];
//        }
    }
    
    return routePartArray;
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailToRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
//    NSLog(@"didFailToRetrieveDefaultRouteTaskParametersWithError:\n%@", error.localizedDescription);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(routeManager:didFailRetrieveDefaultRouteTaskParametersWithError:)]) {
        [self.delegate routeManager:self didFailRetrieveDefaultRouteTaskParametersWithError:error];
    }
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didRetrieveDefaultRouteTaskParameters:(AGSRouteTaskParameters *)routeParams
{
//    NSLog(@"didRetrieveDefaultRouteTaskParameters: %@", routeParams);
    routeTaskParams = routeParams;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(routeManagerDidRetrieveDefaultRouteTaskParameters:)]) {
        [self.delegate routeManagerDidRetrieveDefaultRouteTaskParameters:self];
    }
}


@end
