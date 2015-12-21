//
//  TYAnimatedRouteArrowLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/5/25.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPAnimatedRouteArrowLayer.h"
#import "TYMapEnviroment.h"
#import "IPVector2.h"

@interface IPAnimatedRouteArrowLayer()
{
    NSTimer *timer;
    double currentOffset;
    
    NSArray *lineToShow;

}

@end

@implementation IPAnimatedRouteArrowLayer

+ (IPAnimatedRouteArrowLayer *)animatedRouteArrowLayerWithSpatialReference:(TYSpatialReference *)sr
{
    return [[IPAnimatedRouteArrowLayer alloc] initWithSpatialReference:sr];
}

- (id)initAnimatedRouteArrowWithSpatialReference:(TYSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        
    }
    return self;
}

- (void)showRouteArrow:(NSArray *)array
{
    lineToShow = array;
    
    if (lineToShow == nil) {
        return;
    }
    
    if (timer) {
        [timer invalidate];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showArrowForLines) userInfo:nil repeats:YES];
    
}

#define ANIMATED_ARROW_INTERVAL 0.005
#define OFFSET_INCREASING_INTERVAL 0.002

- (void)showArrowForLines
{
//    NSLog(@"showArrowForLines Fired!");
    [self removeAllGraphics];
    
    if (currentOffset >= ANIMATED_ARROW_INTERVAL) {
        currentOffset = 0;
    }
    currentOffset += OFFSET_INCREASING_INTERVAL;
    
    for (AGSPolyline *line in lineToShow) {
        [self showRouteArrowForLine:line withTranslation:currentOffset];
    }

}

- (void)stopShowingArrow
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }

    lineToShow = nil;
    [self removeAllGraphics];
}



- (void)showRouteArrowForLine:(AGSPolyline *)line withTranslation:(double)translation
{
    double interval = ANIMATED_ARROW_INTERVAL * self.mapView.mapScale;
    double translationInterval = translation * self.mapView.mapScale;
//    double translationInterval = OFFSET_INCREASING_INTERVAL * self.mapView.mapScale;

    
    double totalLength = [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:line];
    int numSegments = (int)line.numPoints - 1;
    int numRoutePoints = (int)((totalLength - translationInterval)/ interval);
    
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
    for (int i = 0; i < numRoutePoints; ++i) {
        double offset = interval * i + translationInterval;
        double currentAccumulativeLength = [accumulativeLengthArray[currentSegmentIndex] doubleValue];
        while (currentAccumulativeLength <= offset) {
            currentSegmentIndex++;
            currentAccumulativeLength = [accumulativeLengthArray[currentSegmentIndex] doubleValue];
        }
        [routePointSegmentArray addObject:@(currentSegmentIndex-1)];
    }
    
    for (int i = 0; i < numRoutePoints; ++i) {
        int currentSegment = [[routePointSegmentArray objectAtIndex:i] intValue];
        
        currentStart = [line pointOnPath:0 atIndex:currentSegment];
        currentEnd = [line pointOnPath:0 atIndex:currentSegment+1];
        
        double currentSegmentLength = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:currentStart toGeometry:currentEnd];
        double currentAccumulativeLength = [[accumulativeLengthArray objectAtIndex:currentSegment] doubleValue];
        
        IPVector2 *v = [[IPVector2 alloc] init];
        v.x = currentEnd.x - currentStart.x;
        v.y = currentEnd.y - currentStart.y;
        double currentAngle = [v getAngle];
        
        AGSPoint *point = [self getPointFrom:currentStart To:currentEnd withSegmentLength:currentSegmentLength withOffset: (i) * interval - currentAccumulativeLength + translationInterval];
        
        TYPictureMarkerSymbol *pms = [TYPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeArrow"];
        
        pms.angle = currentAngle;
        [self addGraphic:[AGSGraphic graphicWithGeometry:point symbol:pms attributes:nil]];
    }
    
}

- (AGSPoint *)getPointFrom:(AGSPoint *)start To:(AGSPoint *)end withSegmentLength:(double)length withOffset:(double)offset
{
    double scale = offset / length;
    
    double x = start.x * (1 - scale) + end.x * scale;
    double y = start.y * (1 - scale) + end.y * scale;
    
    return [AGSPoint pointWithX:x y:y spatialReference:[TYMapEnvironment defaultSpatialReference]];
}

@end
