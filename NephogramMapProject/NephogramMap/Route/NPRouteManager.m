//
//  NPRouteManager.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteManager.h"
#import "NPRoutePointConverter.h"

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


+ (NPRouteManager *)routeManagerWithURL:(NSURL *)url credential:(NPCredential *)credential MapInfos:(NSArray *)mapInfoArray
{
    return [[NPRouteManager alloc] initRouteTaskWithURL:url credential:credential MapInfos:mapInfoArray];
}

- (id)initRouteTaskWithURL:(NSURL *)url credential:(NPCredential *)cr  MapInfos:(NSArray *)mapInfoArray
{
    self = [super init];
    if (self) {
        credential = cr;
        allMapInfos = mapInfoArray;
        
        NPMapInfo *info = [allMapInfos objectAtIndex:0];
        MapSize offset = {200, 0};

        routePointConverter = [[NPRoutePointConverter alloc] initWithBaseMapExtent:info.mapExtent Offset:offset];
        
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
    NSLog(@"didFailSolveWithError:\n%@", error.localizedDescription);
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(routeManager:didFailSolveRouteWithError:)]) {
        [self.delegate routeManager:self didFailSolveRouteWithError:error];
    }
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult
{
    NSLog(@"didSolveWithResult");
    
    AGSRouteResult *routeResult = [routeTaskResult.routeResults firstObject];
    
    if (routeResult) {
        
        NPRouteResult *result = [self processRouteResult:routeResult];
        
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
//    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
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

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailToRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
    NSLog(@"didFailToRetrieveDefaultRouteTaskParametersWithError:\n%@", error.localizedDescription);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(routeManager:didFailRetrieveDefaultRouteTaskParametersWithError:)]) {
        [self.delegate routeManager:self didFailRetrieveDefaultRouteTaskParametersWithError:error];
    }
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didRetrieveDefaultRouteTaskParameters:(AGSRouteTaskParameters *)routeParams
{
    NSLog(@"didRetrieveDefaultRouteTaskParameters: %@", routeParams);
    routeTaskParams = routeParams;
}


@end
