//
//  IPRoutePointConverter.m
//  MapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPRoutePointConverter.h"
#import "TYMapEnviroment.h"

@interface IPRoutePointConverter()
{
    MapExtent baseExtent;
    OffsetSize baseOffset;
}

@end

@implementation IPRoutePointConverter

- (id)initWithBaseMapExtent:(MapExtent)extent Offset:(OffsetSize)offset
{
    self = [super init];
    if (self) {
        baseExtent = extent;
        baseOffset = offset;
    }
    return self;
}

- (AGSPoint *)routePointFromLocalPoint:(TYLocalPoint *)localPoint
{
    double newX = localPoint.x + baseOffset.x * (localPoint.floor - 1);
    return [AGSPoint pointWithX:newX y:localPoint.y spatialReference:[TYMapEnvironment defaultSpatialReference]];
}

- (TYLocalPoint *)localPointFromRoutePoint:(AGSPoint *)routePoint
{
    double xOffset = routePoint.x - baseExtent.xmin;
    
    double grid = xOffset / baseOffset.x;
    int index = floor(grid);
    
    double originX = routePoint.x - index * baseOffset.x;
    double originY = routePoint.y;
    int floor = index + 1;
    return [TYLocalPoint pointWithX:originX Y:originY Floor:floor];
}

- (BOOL)checkPointValidity:(TYLocalPoint *)point
{
    if (point.x >= baseExtent.xmin && point.x <= baseExtent.xmax &&  point.y >= baseExtent.ymin && point.y <= baseExtent.ymax){
        return YES;
    } else {
        return NO;
    }
    
}

@end
