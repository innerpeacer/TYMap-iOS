//
//  NPRouteArrowLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteArrowLayer.h"
#import "Vector2.h"
#import "NPMapEnviroment.h"

@interface NPRouteArrowLayer()
{

}

@end

@implementation NPRouteArrowLayer

+ (NPRouteArrowLayer *)routeArrowLayerWithSpatialReference:(NPSpatialReference *)sr
{
    return [[NPRouteArrowLayer alloc] initWithSpatialReference:sr];
}

- (id)initRouteArrowLayerWithSpatialReference:(NPSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {

    }
    return self;
}

- (void)showRouteArrow:(NSArray *)array
{
    [self removeAllGraphics];
    for (AGSPolyline *line in array) {
        [self showRouteArrowForLine:line];
    }
}

#define ARROW_INTERVAL 0.005
- (void)showRouteArrowForLine:(AGSPolyline *)line
{
    double interval = ARROW_INTERVAL * self.mapView.mapScale;
    double totalLength = [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:line];
    int numSegments = (int)line.numPoints - 1;
    int numRoutePoints = (int)(totalLength / interval);
    
    if (numRoutePoints < 1) {
        return;
    }
    
    AGSPoint *currentStart = nil;
    AGSPoint *currentEnd = nil;
    
    double accumulativeLength = 0;
    NSMutableArray *accumulativeLengthArray =  [[NSMutableArray alloc] init];
    [accumulativeLengthArray addObject:@(accumulativeLength)];
    for (int i = 0; i < numSegments; ++i) {
        currentStart = [line pointOnPath:0 atIndex:i];
        currentEnd = [line pointOnPath:0 atIndex:i+1];
        double currentLength = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:currentStart toGeometry:currentEnd];
        accumulativeLength += currentLength;
        [accumulativeLengthArray addObject:@(accumulativeLength)];
    }
    
    int currentSegmentIndex = 0;
    NSMutableArray *routePointSegmentArray = [[NSMutableArray alloc] init];
    [routePointSegmentArray addObject:@(0)];
    for (int i = 1; i < numRoutePoints; ++i) {
        double offset = interval * i;
        double currentAccumulativeLength = [accumulativeLengthArray[currentSegmentIndex] doubleValue];
        while (currentAccumulativeLength < offset) {
            currentSegmentIndex++;
            currentAccumulativeLength = [accumulativeLengthArray[currentSegmentIndex] doubleValue];
        }
        
        [routePointSegmentArray addObject:@(currentSegmentIndex-1)];
    }
    
    for (int i = 1; i < numRoutePoints; ++i) {
        int currentSegment = [[routePointSegmentArray objectAtIndex:i] intValue];
        
        currentStart = [line pointOnPath:0 atIndex:currentSegment];
        currentEnd = [line pointOnPath:0 atIndex:currentSegment+1];
        
        double currentSegmentLength = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:currentStart toGeometry:currentEnd];
        double currentAccumulativeLength = [[accumulativeLengthArray objectAtIndex:currentSegment] doubleValue];
        
        Vector2 *v = [[Vector2 alloc] init];
        v.x = currentEnd.x - currentStart.x;
        v.y = currentEnd.y - currentStart.y;
        double currentAngle = [v getAngle];
        
        AGSPoint *point = [self getPointFrom:currentStart To:currentEnd withSegmentLength:currentSegmentLength withOffset: (i) * interval - currentAccumulativeLength];
        
        NPPictureMarkerSymbol *pms = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeArrow"];
        
        pms.angle = currentAngle;
        [self addGraphic:[AGSGraphic graphicWithGeometry:point symbol:pms attributes:nil]];
    }
}

- (AGSPoint *)getPointFrom:(AGSPoint *)start To:(AGSPoint *)end withSegmentLength:(double)length withOffset:(double)offset
{
    double scale = offset / length;
    
    double x = start.x * (1 - scale) + end.x * scale;
    double y = start.y * (1 - scale) + end.y * scale;
    
    return [AGSPoint pointWithX:x y:y spatialReference:[NPMapEnvironment defaultSpatialReference]];
}


@end