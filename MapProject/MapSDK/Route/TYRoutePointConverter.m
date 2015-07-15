//
//  TYRoutePointConverter.m
//  MapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYRoutePointConverter.h"
#import "TYMapEnviroment.h"

@interface TYRoutePointConverter()
{
    MapExtent baseExtent;
    MapSize baseOffset;
}

@end

@implementation TYRoutePointConverter

- (id)initWithBaseMapExtent:(MapExtent)extent Offset:(MapSize)offset
{
    self = [super init];
    if (self) {
        baseExtent = extent;
        baseOffset = offset;
    }
    return self;
}

- (TYPoint *)routePointFromLocalPoint:(NPLocalPoint *)localPoint
{
    double newX = localPoint.x + baseOffset.x * (localPoint.floor - 1);
    return [TYPoint pointWithX:newX y:localPoint.y spatialReference:[TYMapEnvironment defaultSpatialReference]];
}

- (NPLocalPoint *)localPointFromRoutePoint:(TYPoint *)routePoint
{
    double xOffset = routePoint.x - baseExtent.xmin;
    
    double grid = xOffset / baseOffset.x;
    int index = floor(grid);
    
    double originX = routePoint.x - index * baseOffset.x;
    double originY = routePoint.y;
    int floor = index + 1;
    return [NPLocalPoint pointWithX:originX Y:originY Floor:floor];
}

- (BOOL)checkPointValidity:(NPLocalPoint *)point
{
    if (point.x >= baseExtent.xmin && point.x <= baseExtent.xmax &&  point.y >= baseExtent.ymin && point.y <= baseExtent.ymax){
        return YES;
    } else {
        return NO;
    }
    
}

@end
