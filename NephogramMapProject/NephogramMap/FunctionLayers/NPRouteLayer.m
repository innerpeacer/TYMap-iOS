//
//  NPRouteLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteLayer.h"
#import "NPGraphic.h"
#import "NPMapView.h"
#import "NPMapEnviroment.h"
#import "Vector2.h"

#import <NephogramData/NephogramData.h>

@interface NPRouteLayer()
{
    AGSSymbol *routeSymbol;
}

@end

@implementation NPRouteLayer

+ (NPRouteLayer *)routeLayerWithSpatialReference:(NPSpatialReference *)sr
{
    return [[NPRouteLayer alloc] initRouteLayerWithSpatialReference:sr];
}

- (id)initRouteLayerWithSpatialReference:(NPSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        routeSymbol = [self createRouteSymbol];
        self.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:routeSymbol];
    }
    return self;
}

#define ARROW_INTERVAL 0.005
- (void)showRouteArrow:(AGSPolyline *)line
{
    double interval = ARROW_INTERVAL * self.mapView.mapScale;
    double totalLength = [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:line];
    int numSegments = (int)line.numPoints - 1;
    int numRoutePoints = (int)(totalLength / interval);

    if (numRoutePoints < 1) {
        return;
    }
    
//    NSLog(@"Interval: %f", interval);
//    NSLog(@"Total Length: %f", totalLength);
//    NSLog(@"Points: %d, Segments: %d", (int)line.numPoints, numSegments);
//    NSLog(@"Route Point: %d", (int)numRoutePoints);
    
    AGSPoint *currentStart = nil;
    AGSPoint *currentEnd = nil;
    
    double accumulativeLength = 0;
    NSMutableArray *accumulativeLengthArray =  [[NSMutableArray alloc] init];
    [accumulativeLengthArray addObject:@0];
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
    
//    NSLog(@"%@", routePointSegmentArray);
    
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
//        NPPictureMarkerSymbol *pms = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"trace"];

        pms.angle = currentAngle;
        [self addGraphic:[AGSGraphic graphicWithGeometry:point symbol:pms attributes:nil]];
        
//        NSLog(@"CurrentSegment: %d", currentSegment);
//        NSLog(@"CurrentAccumulativeLength: %f", currentAccumulativeLength);
//        NSLog(@"SegementLength: %f", interval);
//        NSLog(@"Offset: %f", (i) * interval - currentAccumulativeLength);
//        NSLog(@"%@", point);
        
    }
}

- (AGSPoint *)getPointFrom:(AGSPoint *)start To:(AGSPoint *)end withSegmentLength:(double)length withOffset:(double)offset
{
    double scale = offset / length;
    
//    NSLog(@"scale: %f", scale);
    
    double x = start.x * (1 - scale) + end.x * scale;
    double y = start.y * (1 - scale) + end.y * scale;
    
    return [AGSPoint pointWithX:x y:y spatialReference:[NPMapEnvironment defaultSpatialReference]];
}

- (void)showRouteResultOnFloor:(int)floor
{
    [self removeAllGraphics];
    
    [self showLineForRouteResultOnFloor:floor];
    [self showSymbolForRouteResultOnFloor:floor];
    [self showStartSymbol:self.startPoint];
    [self showEndSymbol:self.endPoint];
}

- (void)showRemaingRouteResultOnFloor:(int)floor WithLocation:(NPLocalPoint *)location
{
    [self removeAllGraphics];
    
    [self showRemainingLineForRouteResultOnFloor:floor WithLocation:location];
    [self showSymbolForRouteResultOnFloor:floor];
    [self showStartSymbol:self.startPoint];
    [self showEndSymbol:self.endPoint];
}

- (void)showSymbolForRouteResultOnFloor:(int)floor
{
    if (_routeResult) {
        AGSPolyline *line = [_routeResult getRouteOnFloor:floor];
        if (line) {
            if ([_routeResult isFirstFloor:floor] && [_routeResult isLastFloor:floor]) {
//                NSLog(@"Same Floor");
                return;
            }
            
            if ([_routeResult isFirstFloor:floor] && ![_routeResult isLastFloor:floor]) {
                NPPoint *p = [_routeResult getLastPointOnFloor:floor];
                if (p) {
                    [self addGraphic:[NPGraphic graphicWithGeometry:p symbol:_switchSymbol attributes:nil]];
                }
                return;
            }
            
            if (![_routeResult isFirstFloor:floor] && [_routeResult isLastFloor:floor]) {
                NPPoint *p = [_routeResult getFirstPointOnFloor:floor];
                if (p) {
                    [self addGraphic:[NPGraphic graphicWithGeometry:p symbol:_switchSymbol attributes:nil]];
                }
                return;
            }
            
            if (![_routeResult isFirstFloor:floor] && ![_routeResult isLastFloor:floor]) {
                NPPoint *fp = [_routeResult getFirstPointOnFloor:floor];
                NPPoint *lp = [_routeResult getLastPointOnFloor:floor];
                if (fp) {
                    [self addGraphic:[NPGraphic graphicWithGeometry:fp symbol:_switchSymbol attributes:nil]];
                }
                
                if (lp) {
                    [self addGraphic:[NPGraphic graphicWithGeometry:lp symbol:_switchSymbol attributes:nil]];
                }
                return;
            }
        }
    }
}

- (void)showLineForRouteResultOnFloor:(int)floor
{
    if (_routeResult) {
        AGSPolyline *line = [_routeResult getRouteOnFloor:floor];
        if (line) {
            [self addGraphic:[NPGraphic graphicWithGeometry:line symbol:nil attributes:nil]];
            [self showRouteArrow:line];
        }
    }
}

- (void)showRemainingLineForRouteResultOnFloor:(int)floor WithLocation:(NPLocalPoint *)location
{
    if (_routeResult) {
        AGSPolyline *line = [_routeResult getRouteOnFloor:floor];
        if (line) {
            AGSPoint *pos = [AGSPoint pointWithX:location.x y:location.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
            AGSPolyline *remainingLine = [self getRemainingLine:line WithPoint:pos];
            if (remainingLine) {
                [self addGraphic:[NPGraphic graphicWithGeometry:remainingLine symbol:nil attributes:nil]];
                [self showRouteArrow:remainingLine];
            }
        }
        
    }
}

- (AGSPolyline *)getRemainingLine:(AGSPolyline *)originalLine WithPoint:(AGSPoint *)point
{
    AGSPolyline *result = nil;
    
    AGSPoint *lastPoint = [originalLine pointOnPath:0 atIndex:originalLine.numPoints-1];
    
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    AGSProximityResult *proximitResult = [engine nearestCoordinateInGeometry:originalLine toPoint:point];
    AGSPoint *cutPoint = proximitResult.point;
    
    AGSMutablePolyline *cutLine = [[AGSMutablePolyline alloc] init];
    [cutLine addPathToPolyline];
    [cutLine addPointToPath:point];
    [cutLine addPointToPath:cutPoint];
    
    NSArray *cuttedLineArray = [engine cutGeometry:originalLine withCutter:cutLine];
//    NSLog(@"%d segments", (int)cuttedLineArray.count);
    
    for (AGSPolyline *line in cuttedLineArray) {
        BOOL isLastHalf = [engine geometry:line touchesGeometry:lastPoint];
        if (isLastHalf) {
            result = line;
        }
    }
    return result;
}

- (void)reset
{
    _routeResult = nil;
    [self removeAllGraphics];
}

- (AGSSymbol *)createRouteSymbol
{
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
//    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
//    sls1.color = [UIColor colorWithRed:41/255.0f green:147/255.0f blue:207/255.0f alpha:1.0f];
//    sls1.style = AGSSimpleLineSymbolStyleSolid;
//    sls1.width = 7;
//    [cs addSymbol:sls1];
//    
//    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
//    sls2.color = [UIColor colorWithRed:43/255.0f green:198/255.0f blue:255/255.0f alpha:1.0f];
//    sls2.style = AGSSimpleLineSymbolStyleSolid;
//    sls2.width = 6;
//    [cs addSymbol:sls2];
    
    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
//    sls1.color = [UIColor colorWithRed:173/255.0f green:8/255.0f blue:8/255.0f alpha:1.0f];
    sls1.color = [UIColor colorWithRed:206/255.0f green:53/255.0f blue:70/255.0f alpha:1.0f];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 8;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
//    sls2.color = [UIColor colorWithRed:255/255.0f green:38/255.0f blue:38/255.0f alpha:1.0f];
    sls2.color = [UIColor colorWithRed:255/255.0f green:89/255.0f blue:89/255.0f alpha:1.0f];
    sls2.style = AGSSimpleLineSymbolStyleSolid;
    sls2.width = 6;
    [cs addSymbol:sls2];
    
    return cs;
}

- (void)showStartSymbol:(NPLocalPoint *)sp
{
    if (sp && sp.floor == self.mapView.currentMapInfo.floorNumber) {
        [self addGraphic:[NPGraphic graphicWithGeometry:[AGSPoint pointWithX:sp.x y:sp.y spatialReference:self.mapView.spatialReference] symbol:_startSymbol attributes:nil]];
    }
}

- (void)showEndSymbol:(NPLocalPoint *)ep
{
    if (ep && ep.floor == self.mapView.currentMapInfo.floorNumber) {
        [self addGraphic:[NPGraphic graphicWithGeometry:[AGSPoint pointWithX:ep.x y:ep.y spatialReference:self.mapView.spatialReference] symbol:_endSymbol attributes:nil]];
    }
}

- (void)showSwitchSymbol:(NPLocalPoint *)sp
{
    if (sp && sp.floor == self.mapView.currentMapInfo.floorNumber) {
        [self addGraphic:[NPGraphic graphicWithGeometry:[AGSPoint pointWithX:sp.x y:sp.y spatialReference:self.mapView.spatialReference] symbol:_switchSymbol attributes:nil]];
    }
}

@end

