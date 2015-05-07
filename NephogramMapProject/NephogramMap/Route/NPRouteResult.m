//
//  NPRouteResult.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteResult.h"
#import "NPMapEnviroment.h"
#import "Vector2.h"
#import "NPDirectionalHint.h"
#import "NPLandmarkManager.h"

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

- (BOOL)isDeviatingFromRoute:(NPLocalPoint *)point WithThrehold:(double)distance
{
    BOOL isDeviating = YES;
    
    int floor = point.floor;
    AGSPoint *pos = [AGSPoint pointWithX:point.x y:point.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
    
    NPPolyline *line = [_routeGraphicDict objectForKey:@(floor)];
    if (line) {
        AGSProximityResult *pr = [[AGSGeometryEngine defaultGeometryEngine] nearestCoordinateInGeometry:line toPoint:pos];
        AGSPoint *nearestedPoint = pr.point;
        
        double nearestedDistance = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:pos toGeometry:nearestedPoint];
        if (nearestedDistance <= distance) {
            isDeviating = NO;
        }
    }
    
    return isDeviating;
}

- (AGSPolyline *)processPolyline:(AGSPolyline *)polyline
{
    if (polyline.numPoints <= 2) {
        return polyline;
    }
    
    AGSMutablePolyline *result = [[AGSMutablePolyline alloc] init];
    [result addPathToPolyline];
    
    double currentAngle = 10000;
    
    int numPoints = (int)polyline.numPoints;
    
    for (int i = 0; i < numPoints - 1; ++i) {
        AGSPoint *p0 = [polyline pointOnPath:0 atIndex:i];
        AGSPoint *p1 = [polyline pointOnPath:0 atIndex:i+1];
        
        
#define DISTANCE_THREHOLD 5.0
#define ANGLE_THREHOLD 10.0
        
        double distance = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:p0 toGeometry:p1];
        if (distance < DISTANCE_THREHOLD) {
            continue;
        }
        
        Vector2 *v = [[Vector2 alloc] init];
        v.x = p1.x - p0.x;
        v.y = p1.y - p0.y;
        double angle = [v getAngle];

//        if (currentAngle != angle) {
        if (ABS(currentAngle - angle) > ANGLE_THREHOLD) {
            [result addPointToPath:p0];
            currentAngle = angle;
        }
    }

    [result addPointToPath:[polyline pointOnPath:0 atIndex:numPoints - 1]];
    
    return result;
}

- (NSArray *)getRouteDirectionHintOnFloor:(NPMapInfo *)info
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NPLandmarkManager *landmarkManager = [NPLandmarkManager sharedManager];
    [landmarkManager loadLandmark:info];
    
    NPPolyline *originalLine = [_routeGraphicDict objectForKey:@(info.floorNumber)];
    AGSPolyline *line = [self processPolyline:originalLine];
    
    double currentAngle = INITIAL_EMPTY_ANGLE;
    
    if (line) {
        
        int numPoints = (int)line.numPoints;
        
        for (int i = 0; i < numPoints - 1; ++i) {
            AGSPoint *p0 = [line pointOnPath:0 atIndex:i];
            AGSPoint *p1 = [line pointOnPath:0 atIndex:i+1];
            
            NPLocalPoint *lp = [NPLocalPoint pointWithX:p0.x Y:p0.y Floor:info.floorNumber];
            
            NPLandmark *landmark = [landmarkManager searchLandmark:lp Tolerance:10];
            
            
            NPDirectionalHint *ds = [[NPDirectionalHint alloc] initWithStartPoint:p0 EndPoint:p1 PreviousAngle:currentAngle];
            currentAngle = ds.currentAngle;
            
            if (landmark) {
                ds.landMark = landmark;
            }
            
            [result addObject:ds];
        }
    }
    
    return result;
}

- (NPDirectionalHint *)getDirectionHintForLocation:(NPLocalPoint *)location FromHints:(NSArray *)directions
{
    AGSMutablePolyline *line = [[AGSMutablePolyline alloc] init];
    [line addPathToPolyline];
    
    for (NPDirectionalHint *hint in directions) {
        [line addPointToPath:hint.startPoint];
    }
    
    NPDirectionalHint *lastHint = [directions lastObject];
    if (lastHint) {
        [line addPointToPath:lastHint.endPoint];
    }
    
    AGSPoint *pos = [AGSPoint pointWithX:location.x y:location.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
    AGSProximityResult *pr = [[AGSGeometryEngine defaultGeometryEngine] nearestCoordinateInGeometry:line toPoint:pos];

    int index = (int)pr.pointIndex;
    
    return [directions objectAtIndex:index];
}

+ (AGSPolyline *)getSubPolyline:(AGSPolyline *)originalLine WithStart:(AGSPoint *)start End:(AGSPoint *)end
{
    int startIndex = -1;
    int endIndex = -1;
    int numPoints = (int)originalLine.numPoints;
    for (int i = 0; i < numPoints; ++i) {
        AGSPoint *p = [originalLine pointOnPath:0 atIndex:i];
        
        if (start.x == p.x && start.y == p.y) {
            startIndex = i;
        }
        
        if (end.x == p.x && end.y == p.y) {
            endIndex = i;
            break;
        }
    }
    
    if (startIndex == -1 || endIndex == -1) {
        return nil;
    }
    
    AGSMutablePolyline *result = [[AGSMutablePolyline alloc] init];
    [result addPathToPolyline];
    
    for (int i = startIndex; i <= endIndex; ++i) {
        AGSPoint *p = [originalLine pointOnPath:0 atIndex:i];
        [result addPointToPath:p];
    }
    
    return result;
}

@end
