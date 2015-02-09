//
//  NPRouteManager.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteManager.h"

@interface NPRouteManager() <AGSRouteTaskDelegate>
{
    AGSRouteTask *routeTask;
    AGSRouteTaskParameters *routeTaskParams;
    AGSRouteResult *routeResult;
    AGSCredential *credential;
}

@end

@implementation NPRouteManager


+ (NPRouteManager *)routeManagerWithURL:(NSURL *)url credential:(AGSCredential *)credential
{
    return [[NPRouteManager alloc] initRouteTaskWithURL:url credential:credential];
}

- (id)initRouteTaskWithURL:(NSURL *)url credential:(AGSCredential *)cr
{
    self = [super init];
    if (self) {
        credential = cr;
        routeTask = [AGSRouteTask routeTaskWithURL:url credential:cr];
        routeTask.delegate = self;
        [routeTask retrieveDefaultRouteTaskParameters];
    }
    
    return self;
}

- (void)requestRouteWithStart:(AGSPoint *)start End:(AGSPoint *)end
{
    NSMutableArray *stops = [NSMutableArray array];
    [stops addObject:[AGSGraphic graphicWithGeometry:start symbol:nil attributes:nil]];
    [stops addObject:[AGSGraphic graphicWithGeometry:end symbol:nil attributes:nil]];
    
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
    routeResult = [routeTaskResult.routeResults firstObject];
    //    NSLog(@"%d routes in result",(int)routeTaskResult.routeResults.count);
    
    if (routeResult) {
        //        NSLog(@"routeResult: %@", routeResult);
        if (self.delegate != nil || [self.delegate respondsToSelector:@selector(routeManager:didSolveRouteWithResult:)]) {
            [self.delegate routeManager:self didSolveRouteWithResult:routeResult.routeGraphic];
        }
    }
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
    NSLog(@"didRetrieveDefaultRouteTaskParameters");
    routeTaskParams = routeParams;
}


@end
