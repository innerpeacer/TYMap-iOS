//
//  NPRouteResultV2.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteResultV2.h"
#import "NPLandmarkManager.h"
#import "Vector2.h"
#import "NPPolyline.h"
#import "NPMapEnviroment.h"

@interface NPRouteResultV2()
{

}

@end

@implementation NPRouteResultV2

+ (NPRouteResultV2 *)routeResultWithRouteParts:(NSArray *)routePartArray
{
    return [[NPRouteResultV2 alloc] initRouteResultWithRouteParts:routePartArray];
}

- (id)initRouteResultWithRouteParts:(NSArray *)routePartArray
{
    self = [super init];
    if (self) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObjectsFromArray:routePartArray];
        _allRoutePartsArray = tempArray;
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < tempArray.count; ++i) {
            NPRoutePart *rp = tempArray[i];
            int floor = rp.info.floorNumber;
            
            if (![tempDict.allKeys containsObject:@(floor)]) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [tempDict setObject:array forKey:@(floor)];
            }
            
            NSMutableArray *array = [tempDict objectForKey:@(floor)];
            [array addObject:rp];
        }
        _allFloorRoutePartDict = tempDict;
    }
    return self;
}

- (BOOL)isDeviatingFromRoute:(NPLocalPoint *)point WithThrehold:(double)distance
{
    BOOL isDeviating = YES;
    
    int floor = point.floor;
    AGSPoint *pos = [AGSPoint pointWithX:point.x y:point.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
    
    NSArray *rpArray = [_allFloorRoutePartDict objectForKey:@(floor)];
    if (rpArray && rpArray.count > 0) {
        for (NPRoutePart *rp in rpArray) {
            AGSProximityResult *pr = [[AGSGeometryEngine defaultGeometryEngine] nearestCoordinateInGeometry:rp.route toPoint:pos];
            AGSPoint *nearestPoint = pr.point;
            
            double nearestDistance = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:pos toGeometry:nearestPoint];
            if (nearestDistance <= distance) {
                isDeviating = NO;
                return isDeviating;
            }
        }
    }
    return isDeviating;
}

- (NPRoutePart *)getNearestRoutePart:(NPLocalPoint *)location
{
    NPRoutePart *result = nil;
    
    int floor = location.floor;
    double nearestDistance = 1000000;
    
    AGSPoint *pos = [AGSPoint pointWithX:location.x y:location.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
    
    NSArray *rpArray = [_allFloorRoutePartDict objectForKey:@(floor)];
    if (rpArray && rpArray.count > 0) {
        for (NPRoutePart *rp in rpArray) {
            AGSProximityResult *pr = [[AGSGeometryEngine defaultGeometryEngine] nearestCoordinateInGeometry:rp.route toPoint:pos];
            AGSPoint *nearestPoint = pr.point;
            
            double distance = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:pos toGeometry:nearestPoint];
            if (distance < nearestDistance) {
                nearestDistance = distance;
                result = rp;
            }
        }
    }
    return result;
}

- (NSArray *)getRoutePartsOnFloor:(int)floor
{
    return [_allFloorRoutePartDict objectForKey:@(floor)];
}

- (NPRoutePart *)getRoutePart:(int)index
{
    return [_allRoutePartsArray objectAtIndex:index];
}

- (NSArray *)getRouteDirectionalHint:(NPRoutePart *)rp
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NPLandmarkManager *landmarkManager = [NPLandmarkManager sharedManager];
    [landmarkManager loadLandmark:rp.info];

    AGSPolyline *line = [self processPolyline:rp.route];
    
    double currentAngle = INITIAL_EMPTY_ANGLE;
    
    if (line) {
        
        int numPoints = (int)line.numPoints;
        
        for (int i = 0; i < numPoints - 1; ++i) {
            AGSPoint *p0 = [line pointOnPath:0 atIndex:i];
            AGSPoint *p1 = [line pointOnPath:0 atIndex:i+1];
            
            NPLocalPoint *lp = [NPLocalPoint pointWithX:p0.x Y:p0.y Floor:rp.info.floorNumber];
            
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
        
        if (ABS(currentAngle - angle) > ANGLE_THREHOLD) {
            [result addPointToPath:p0];
            currentAngle = angle;
        }
    }
    
    [result addPointToPath:[polyline pointOnPath:0 atIndex:numPoints - 1]];
    
    return result;
}

@end
