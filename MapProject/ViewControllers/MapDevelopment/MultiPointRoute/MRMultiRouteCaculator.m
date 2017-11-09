//
//  MRMultiRouteCaculator.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRMultiRouteCaculator.h"

@interface MRMultiRouteCaculator()
{
    MRParams *routeParams;
    NSDictionary *routeDict;
    int stopCount;
    
    double minDistance;
    NSMutableArray *shortestRoute;
}
@end

@implementation MRMultiRouteCaculator

- (id)initWithStart:(MRSuperNode *)start End:(MRSuperNode *)end Stops:(NSArray *)stops Dict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithRouteParam:(MRParams *)params Dict:(NSDictionary *)d
{
    self = [super init];
    if (self) {
        routeParams = params;
        stopCount = (int)[routeParams getStopNodes].count;
        routeDict = d;
    }
    return self;
}

- (AGSPolyline *)calculate
{
    NSLog(@"calculate");
    NSArray *stopArray = [routeParams getStopNodes];
    int indexs[stopArray.count];
    for (int i = 0; i < stopArray.count; ++i) {
        indexs[i] = i;
    }
    
    minDistance = 10000000000;
    [self fullArray:indexs cursor:0 end:(int)stopArray.count - 1];
    
    return [self getShortestRouteLine];
}

- (NSArray *)getRouteCollection
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    AGSPolyline *line = nil;
    NSString *key = nil;
    
//    MRSuperNode *startNode = [routeParams getStartNode];
//    MRSuperNode *endNode = [routeParams getEndNode];
    NSArray *stopArray = [routeParams getStopNodes];
    
    NSLog(@"================ RestoreKey ===============");
    {
        MRSuperNode *startNode = [routeParams getStartNode];
        MRSuperNode *firstStop = stopArray[[shortestRoute[0] intValue]];
        key = [self getKeyWithNode1:startNode Node2:firstStop];
        line = routeDict[key];
        NSLog(@"Key: %@ => %d", key, (int)[line numPoints]);
        [resultArray addObject:line];
    }
    
    {
        for (int i = 0; i < stopCount - 1; ++i) {
            MRSuperNode *stop1 = stopArray[[shortestRoute[i] intValue]];
            MRSuperNode *stop2 = stopArray[[shortestRoute[i + 1] intValue]];
            key = [self getKeyWithNode1:stop1 Node2:stop2];
            line = routeDict[key];
            NSLog(@"Key: %@ => %d", key, (int)[line numPoints]);
            [resultArray addObject:line];
        }
    }
    
    {
        MRSuperNode *endNode = [routeParams getEndNode];
        MRSuperNode *lastStop = stopArray[[shortestRoute[stopCount - 1] intValue]];
        key = [self getKeyWithNode1:lastStop Node2:endNode];
        line = routeDict[key];
        line = routeDict[key];
        [resultArray addObject:line];
    }
    return resultArray;
}

- (AGSPolyline *)getShortestRouteLine
{
    AGSMutablePolyline *resultLine = [[AGSMutablePolyline alloc] init];
    [resultLine addPathToPolyline];

    AGSPolyline *line = nil;
    NSString *key = nil;
    
    MRSuperNode *startNode = [routeParams getStartNode];
    MRSuperNode *endNode = [routeParams getEndNode];
    NSArray *stopArray = [routeParams getStopNodes];
    
    NSLog(@"nodes: %@", shortestRoute);
    NSLog(@"routeDict: %@", routeDict);
    NSLog(@"================ ComputeKey ===============");
    {
        MRSuperNode *firstStop = stopArray[[shortestRoute[0] intValue]];
        key = [self getKeyWithNode1:startNode Node2:firstStop];
        NSLog(@"Key: %@", key);
        line = routeDict[key];
        for (int i = 0; i < [line numPointsInPath:0]; ++i) {
            [resultLine addPointToPath:[line pointOnPath:0 atIndex:i]];
        }
    }
    
    {
        for (int i = 0; i < stopCount - 1; ++i) {
            MRSuperNode *stop1 = stopArray[[shortestRoute[i] intValue]];
            MRSuperNode *stop2 = stopArray[[shortestRoute[i + 1] intValue]];
            key = [self getKeyWithNode1:stop1 Node2:stop2];
            NSLog(@"Key: %@", key);
            line = routeDict[key];
            for (int i = 0; i < [line numPointsInPath:0]; ++i) {
                [resultLine addPointToPath:[line pointOnPath:0 atIndex:i]];
            }
        }
    }
    
    {
        MRSuperNode *lastStop = stopArray[[shortestRoute[stopCount - 1] intValue]];
        key = [self getKeyWithNode1:lastStop Node2:endNode];
        NSLog(@"Key: %@", key);
        line = routeDict[key];
        for (int i = 0; i < [line numPointsInPath:0]; ++i) {
            [resultLine addPointToPath:[line pointOnPath:0 atIndex:i]];
        }
    }
    return resultLine;
}

- (void)swap:(int [])array cursor:(int)cursor index:(int)i
{
    int temp = array[cursor];
    array[cursor] = array[i];
    array[i] = temp;
}

- (void)fullArray:(int [])array cursor:(int)cursor end:(int)end
{
    if (cursor == end) {
        double distance = [self getDistance:array];

        if (distance < minDistance) {
            minDistance = distance;
            shortestRoute = [NSMutableArray array];
            for (int i = 0; i < stopCount; ++i) {
                shortestRoute[i] = @(array[i]);
            }
            printf("%d, %d, %d, %d\n", array[0], array[1], array[2], array[3]);
            printf("distance: %f\n", distance);
        }
        
    } else {
        for (int i = cursor; i <= end; i++) {
            [self swap:array cursor:cursor index:i];
            [self fullArray:array cursor:cursor + 1 end:end];
            [self swap:array cursor:cursor index:i];
            //            swap(array, cursor, i);
            //            fullArray(array, cursor + 1, end);
            //            swap(array, cursor, i);
        }
    }
}

- (double)getDistance:(int [])array
{
    double distance = 0;
    AGSPolyline *line = nil;
    NSString *key = nil;
    
    MRSuperNode *startNode = [routeParams getStartNode];
    MRSuperNode *endNode = [routeParams getEndNode];
    NSArray *stopArray = [routeParams getStopNodes];
    
    {
        MRSuperNode *firstStop = stopArray[array[0]];
        key = [self getKeyWithNode1:startNode Node2:firstStop];
        line = routeDict[key];
        distance += [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:line];
    }
    
    {
        for (int i = 0; i < stopCount - 1; ++i) {
            MRSuperNode *stop1 = stopArray[array[i]];
            MRSuperNode *stop2 = stopArray[array[i + 1]];
            key = [self getKeyWithNode1:stop1 Node2:stop2];
            line = routeDict[key];
            distance += [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:line];
        }
    }
    
    {
        MRSuperNode *lastStop = stopArray[array[stopCount - 1]];
        key = [self getKeyWithNode1:lastStop Node2:endNode];
        line = routeDict[key];
        distance += [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:line];
    }
    
    return distance;
}



- (NSString *)getKeyWithNode1:(MRSuperNode *)node1 Node2:(MRSuperNode *)node2
{
    return [NSString stringWithFormat:@"%d-%d", node1.nodeID, node2.nodeID];
}

@end

