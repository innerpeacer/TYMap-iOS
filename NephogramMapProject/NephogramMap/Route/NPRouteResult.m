//
//  NPRouteResult.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteResult.h"

@interface NPRouteResult()
{
    
}

@end

@implementation NPRouteResult

+ (NPRouteResult *)routeResultWithDict:(NSDictionary *)dict FloorArray:(NSArray *)array
{
    return [[NPRouteResult alloc] initRouteResultWithDict:dict FloorArray:array];
}


- (id)initRouteResultWithDict:(NSDictionary *)dict FloorArray:(NSArray *)array;
{
    self = [super init];
    if (self) {
        _routeGraphicDict = dict;
        _routeFloorArray = array;
    }
    return self;
}

- (NPPolyline *)getRouteOnFloor:(int)floorIndex
{
    return [_routeGraphicDict objectForKey:@(floorIndex)];
}

- (NPPoint *)getFirstPointOnFloor:(int)floorIndex
{
    NPPoint *result = nil;
    
    NPPolyline *line = [_routeGraphicDict objectForKey:@(floorIndex)];
    if (line && line.numPaths && line.numPoints) {
        result = (NPPoint *) [line pointOnPath:0 atIndex:0];
    }
    return result;
}

- (NPPoint *)getLastPointOnFloor:(int)floorIndex
{
    NPPoint *result = nil;
    
    NPPolyline *line = [_routeGraphicDict objectForKey:@(floorIndex)];
    if (line && line.numPaths && line.numPoints) {
        int num = (int)[line numPointsInPath:0];
        result = (NPPoint *)[line pointOnPath:0 atIndex:num -1];
    }
    return result;
}

- (BOOL)isFirstFloor:(int)floorIndex
{
    return [_routeFloorArray.firstObject intValue] == floorIndex;
}

- (BOOL)isLastFloor:(int)floorIndex
{
    return [_routeFloorArray.lastObject intValue] == floorIndex;
}

- (NSNumber *)getPreviousFloor:(int)floorIndex
{
    NSUInteger index = [_routeFloorArray indexOfObject:@(floorIndex)];
    if (index == NSNotFound || index == 0) {
        return nil;
    }
    return [_routeFloorArray objectAtIndex:index -1];
}

- (NSNumber *)getNextFloor:(int)floorIndex
{
    NSUInteger index = [_routeFloorArray indexOfObject:@(floorIndex)];
    if (index == NSNotFound || index == _routeFloorArray.count -1) {
        return nil;
    }
    return [_routeFloorArray objectAtIndex:index+1];
}

@end
