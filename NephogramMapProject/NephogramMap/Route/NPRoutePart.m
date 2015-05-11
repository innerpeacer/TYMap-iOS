//
//  NPRoutePart.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRoutePart.h"

@implementation NPRoutePart

- (id)initWithRouteLine:(AGSPolyline *)route MapInfo:(NPMapInfo *)mapInfo
//- (id)initWithRouteLine:(AGSPolyline *)route Floor:(int)floor
{
    self = [super init];
    if (self) {
        _route = route;
//        _floor = floor;
        _info = mapInfo;
    }
    return self;
}

- (BOOL)isFirstPart
{
    return (_previousPart == nil);
}

- (BOOL)isLastPart
{
    return (_nextPart == nil);
}

- (BOOL)isMiddlePart
{
    return ((_previousPart != nil) && (_nextPart != nil));
}

- (NSString *)description
{
    NSString *part = @"Last";
    if ([self isMiddlePart]) {
        part = @"Middle";
    }
    
    if ([self isFirstPart]) {
        part = @"First";
    }
    
    return [NSString stringWithFormat:@"%@ Part on Floor: %d", part, _info.floorNumber];
}

- (AGSPoint *)getFirstPoint
{
    AGSPoint *result = nil;
    if (_route) {
        result = [_route pointOnPath:0 atIndex:0];
    }
    return result;
}

- (AGSPoint *)getLastPoint
{
    AGSPoint *result = nil;
    if (_route) {
        int numPoint = (int)_route.numPoints;
        result = [_route pointOnPath:0 atIndex:numPoint-1];
    }
    return result;
}

@end
