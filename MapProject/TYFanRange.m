//
//  TYFanRange.m
//  BLEProject
//
//  Created by innerpeacer on 2017/5/15.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "TYFanRange.h"

#define PI 3.1415926
#define BRT_ANGLE_TO_RAD(X) (PI * X)/180.0
#define BRT_RAD_TO_ANGLE(X) (X / PI)*180.0

#define DEFAULT_HALF_ANGLE 45
#define DEFAULT_FAN_RANGE 50

@interface TYFanRange()
{
    double halfAngle;
    double range;
    
    TYLocalPoint *center;
    NSNumber *heading;
}

@end

@implementation TYFanRange
@synthesize center = center;

- (id)init
{
    self = [super init];
    if (self) {
        halfAngle = DEFAULT_HALF_ANGLE;
        range = DEFAULT_FAN_RANGE;
    }
    return self;
}

- (id)initWithCenter:(TYLocalPoint *)c Heading:(NSNumber *)h
{
    self = [super init];
    if (self) {
        center = c;
        heading = h;
        
        halfAngle = DEFAULT_HALF_ANGLE;
        range = DEFAULT_FAN_RANGE;
    }
    return self;
}

- (void)updateCenter:(TYLocalPoint *)c
{
    center = c;
}

- (void)updateHeading:(double)h
{
    heading = @(h);
}

- (AGSGeometry *)toFanGeometry
{
    if (center == nil || heading == nil) {
        return nil;
    }
    
    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] init];
    [polygon addRingToPolygon];
    [polygon addPointToRing:[AGSPoint pointWithX:center.x y:center.y spatialReference:nil]];
    
    double angleStep = 2;
    double startAngle = heading.doubleValue - halfAngle;
    double endAngle = heading.doubleValue + halfAngle;
    
    [polygon addPointToRing:[self getPoint:startAngle]];
    for (double angle = startAngle + angleStep; angle < endAngle; angle += angleStep) {
        [polygon addPointToRing:[self getPoint:angle]];
    }
    
    [polygon addPointToRing:[self getPoint:endAngle]];
    return  polygon;
}

- (AGSGeometry *)toArcGeometry
{
    if (center == nil || heading == nil) {
        return nil;
    }
    
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    
    double angleStep = 2;
    double startAngle = heading.doubleValue - halfAngle;
    double endAngle = heading.doubleValue + halfAngle;
    
    [polyline addPointToPath:[self getPoint:startAngle]];
    for (double angle = startAngle + angleStep; angle < endAngle; angle += angleStep) {
        [polyline addPointToPath:[self getPoint:angle]];
    }
    return polyline;
}

- (AGSGeometry *)toArcGeometry1WithStartAngle:(double)startAngle endAngle:(double)endAngle
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    
    double angleStep = 2;
    
    [polyline addPointToPath:[self getPoint:startAngle]];
    for (double angle = startAngle + angleStep; angle < endAngle; angle += angleStep) {
        [polyline addPointToPath:[self getPoint:angle]];
    }
    return polyline;
}

- (AGSGeometry *)toArcGeometry2WithStartAngle:(double)startAngle endAngle:(double)endAngle
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    
    double angleStep = 2;
    [polyline addPointToPath:[self getPoint:startAngle]];
    for (double angle = startAngle + angleStep; angle < endAngle; angle += angleStep) {
        [polyline addPointToPath:[self getPoint:angle]];
    }
    return polyline;
}

- (TYLocalPoint *)getLocalPoint:(double)angle
{
    double x = center.x + sin(BRT_ANGLE_TO_RAD(angle)) * range;
    double y = center.y + cos(BRT_ANGLE_TO_RAD(angle)) * range;
    return [TYLocalPoint pointWithX:x Y:y Floor:center.floor];
}

- (AGSPoint *)getPoint:(double)angle
{
    double x = center.x + sin(BRT_ANGLE_TO_RAD(angle)) * range;
    double y = center.y + cos(BRT_ANGLE_TO_RAD(angle)) * range;
    return [AGSPoint pointWithX:x y:y spatialReference:nil];
}

@end
