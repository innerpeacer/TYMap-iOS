//
//  TYRouteManager.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYRouteManager.h"
#import "TYRoutePointConverter.h"
#import "TYBuilding.h"
#import "TYRoutePart.h"

@interface TYRouteManager() <AGSRouteTaskDelegate>
{
    AGSRouteTask *routeTask;
    AGSRouteTaskParameters *routeTaskParams;
    TYCredential *credential;

    NSArray *allMapInfos;
    
    TYRoutePointConverter *routePointConverter;
}

@end

@implementation TYRouteManager


+ (TYRouteManager *)routeManagerWithBuilding:(TYBuilding *)building credential:(TYCredential *)credential MapInfos:(NSArray *)mapInfoArray
{
    return [[TYRouteManager alloc] initRouteTaskWithBuilding:building credential:credential MapInfos:mapInfoArray];
}

- (id)initRouteTaskWithBuilding:(TYBuilding *)building credential:(TYCredential *)cr  MapInfos:(NSArray *)mapInfoArray
{
    self = [super init];
    if (self) {
        credential = cr;
        allMapInfos = mapInfoArray;
        
        TYMapInfo *info = [allMapInfos objectAtIndex:0];
        routePointConverter = [[TYRoutePointConverter alloc] initWithBaseMapExtent:info.mapExtent Offset:building.offset];
        
        NSURL *url = [NSURL URLWithString:building.routeURL];
        routeTask = [AGSRouteTask routeTaskWithURL:url credential:cr];
        routeTask.delegate = self;
        [routeTask retrieveDefaultRouteTaskParameters];
    }
    
    return self;
}

- (void)requestRouteWithStart:(TYLocalPoint *)start End:(TYLocalPoint *)end
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
    routeTaskParams.returnDirections = NO;
    
    routeTaskParams.findBestSequence = YES;
    routeTaskParams.preserveFirstStop = YES;
    routeTaskParams.preserveLastStop = YES;
    
    routeTaskParams.returnStopGraphics = YES;
    routeTaskParams.outSpatialReference = [TYMapEnvironment defaultSpatialReference];
    
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
        TYRouteResult *result = [self processRouteResult:routeResult];
        
        if (result == nil) {
            return;
        }
        
        if (self.delegate != nil || [self.delegate respondsToSelector:@selector(routeManager:didSolveRouteWithResult:)]) {
            [self.delegate routeManager:self didSolveRouteWithResult:result];
        }
    }
}

- (TYRouteResult *)processRouteResult:(AGSRouteResult *)rs
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
            
            TYPoint *p = (TYPoint *)[routeLine pointOnPath:0 atIndex:i];
            TYLocalPoint *lp = [routePointConverter localPointFromRoutePoint:p];
            BOOL isValid = [routePointConverter checkPointValidity:lp];
            if (isValid) {
                
                if (lp.floor != currentFloor) {
                    currentFloor = lp.floor;
                    NSLog(@"process currentFloor: %d", currentFloor);

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
