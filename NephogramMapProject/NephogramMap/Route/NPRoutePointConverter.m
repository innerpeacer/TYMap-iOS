//
//  NPRoutePointConverter.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRoutePointConverter.h"
#import "NPMapEnviroment.h"

@interface NPRoutePointConverter()
{
    MapExtent baseExtent;
    MapSize baseOffset;
}

@end

@implementation NPRoutePointConverter

- (id)initWithBaseMapExtent:(MapExtent)extent Offset:(MapSize)offset
{
    self = [super init];
    if (self) {
        baseExtent = extent;
        baseOffset = offset;
    }
    return self;
}

- (AGSPoint *)routePointFromLocalPoint:(NPLocalPoint *)localPoint
{
    double newX = localPoint.x + baseOffset.x * (localPoint.floor - 1);
    return [AGSPoint pointWithX:newX y:localPoint.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
}

- (NPLocalPoint *)localPointFromRoutePoint:(AGSPoint *)routePoint
{
    double xOffset = routePoint.x - baseExtent.xmin;
    
    double grid = xOffset / baseOffset.x;
    int index = floor(grid);
    
    double originX = routePoint.x - index * baseOffset.x;
    double originY = routePoint.y;
    int floor = index + 1;
    return [NPLocalPoint pointWithX:originX Y:originY Floor:floor];
}

- (BOOL)checkPointValid:(NPLocalPoint *)point
{
    if (point.x >= baseExtent.xmin && point.x <= baseExtent.xmax &&  point.y >= baseExtent.ymin && point.y <= baseExtent.ymax){
        return YES;
    } else {
        return NO;
    }
    
}

@end
