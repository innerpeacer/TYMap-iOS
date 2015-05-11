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
