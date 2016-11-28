//
//  TYTraceLayerV2.m
//  MapProject
//
//  Created by innerpeacer on 2016/11/26.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "TYLitsoTraceLayer.h"

@interface TYLitsoTraceLayer()
{
    int targetFloor;
    
    int currentFloor;
    int currentStartIndex;
    
    AGSSimpleLineSymbol *outlineSymbol;
    AGSSimpleLineSymbol *traceSymbol1;
    AGSSimpleLineSymbol *traceSymbol2;
    
    AGSSimpleLineSymbol *lineSymbol;
    AGSSimpleMarkerSymbol *pointSymbol;
    
    NSMutableArray<NSNumber *> *traceFloorArray;
    NSMutableArray<NSNumber *> *traceStartIndexArray;
    NSMutableArray<NSMutableArray <TYTraceLocalPoint *> *> *tracePointArray;
    NSMutableArray<NSMutableArray <NSNumber *> *> *traceCoordinateArray;
    NSMutableArray<AGSPolyline *> *traceLineArray;
    
    NSMutableDictionary <NSString *, TYLocalPoint *> *themeLocations;
}

@end

@implementation TYLitsoTraceLayer


- (id)initWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        outlineSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor whiteColor] width:1.0f];
        pointSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
        pointSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
        pointSymbol.size = CGSizeMake(15, 15);
        pointSymbol.outline = outlineSymbol;
        [self setRenderer:[AGSSimpleRenderer simpleRendererWithSymbol:pointSymbol]];
        
        lineSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:2.0];
        lineSymbol.style = AGSSimpleLineSymbolStyleDash;
        
        traceSymbol1 = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor whiteColor] width:8.0f];
        traceSymbol2 = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:1.0f green:89/255.0f blue:89/255.0f alpha:1.0f] width:6.0f];
        
        traceFloorArray = [[NSMutableArray alloc] init];
        traceStartIndexArray = [[NSMutableArray alloc] init];
        tracePointArray = [[NSMutableArray alloc] init];
        traceCoordinateArray = [[NSMutableArray alloc] init];
        traceLineArray = [[NSMutableArray alloc] init];
        
        themeLocations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setFloor:(int)floor
{
    NSLog(@"setFloor: %d", floor);
    targetFloor = floor;
}

- (void)addTracePoints:(NSArray *)pointArray WithThemes:(NSDictionary *)themes
{
    [themeLocations removeAllObjects];
    [themeLocations addEntriesFromDictionary:themes];
    
    for (int i = 0; i < pointArray.count; ++i) {
        [self addTracePoint:pointArray[i]];
    }
}

//- (void)addTracePoints:(NSArray *)pointArray
//{
//    for (int i = 0; i < pointArray.count; ++i) {
//        [self addTracePoint:pointArray[i]];
//    }
//}

- (void)addTracePoint:(TYTraceLocalPoint *)point
{
    if (currentFloor != point.location.floor) {
        currentFloor = point.location.floor;
        
        [traceFloorArray addObject:@(currentFloor)];
        [traceStartIndexArray addObject:@(currentStartIndex)];
        [tracePointArray addObject:[NSMutableArray array]];
        [traceCoordinateArray addObject:[NSMutableArray array]];
        [traceLineArray addObject:[[AGSMutablePolyline alloc] init]];
    }
    
    currentStartIndex++;
    
    NSMutableArray *tracePoints = tracePointArray[tracePointArray.count -1];
    [tracePoints addObject:point];
    
    NSMutableArray *traceCoordinates = traceCoordinateArray[traceCoordinateArray.count - 1];
    [traceCoordinates addObject:@[@(point.location.x), @(point.location.y)]];
    
    traceLineArray[traceLineArray.count - 1] = [self createLineFromCoordinates:traceCoordinates];
}

- (void)showSnappedTraces:(TYSnappingManager *)snappingManager
{
    NSLog(@"showSnappedTraces");
    [self removeAllGraphics];
    
    for (int i = 0; i < traceFloorArray.count; ++i) {
        int traceFloor = [traceFloorArray[i] intValue];
        if (targetFloor == traceFloor) {
            NSArray *tracePoints = tracePointArray[i];
            int traceIndex = [traceStartIndexArray[i] intValue];
            
            AGSPoint *lastSnappedTracePoint = nil;
            int lastSnappedVertexIndex = -1;
            
            NSMutableArray *snappedTraceLineArray = [NSMutableArray array];
            NSMutableArray *snappedTracePointArray = [NSMutableArray array];
            
            NSString *lastThemeID = nil;
            
            int testCount =0;
            for (int j = 0; j < tracePoints.count; ++j) {
                TYTraceLocalPoint *originalTracePoint = tracePoints[j];
                
                TYLocalPoint *themeLocation;
                AGSProximityResult *snappedObject;
                
                if (originalTracePoint.inTheme) {
                    if (lastThemeID != nil && [lastThemeID isEqualToString:originalTracePoint.themeID]) {
                        continue;
                    }
                    lastThemeID = originalTracePoint.themeID;
                    themeLocation = themeLocations[originalTracePoint.themeID];
                    //                    NSLog(@"%@", themeLocation);
                    snappedObject = [snappingManager getSnappedResult:themeLocation];
                } else {
                    snappedObject = [snappingManager getSnappedResult:originalTracePoint.location];
                }
                
                //                AGSProximityResult *snappedObject = [snappingManager getSnappedResult:originalTracePoint];
                AGSPoint *snappedPoint = snappedObject.point;
                
                if (lastSnappedTracePoint == nil) {
                    lastSnappedTracePoint = snappedPoint;
                } else {
                    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:MIN(lastSnappedTracePoint.x, snappedPoint.x) ymin:MIN(lastSnappedTracePoint.y, snappedPoint.y) xmax:MAX(lastSnappedTracePoint.x, snappedPoint.x) ymax:MAX(lastSnappedTracePoint.y, snappedPoint.y) spatialReference:nil];
                    NSDictionary *geometries = [snappingManager getRouteGeometries];
                    AGSPolyline *cuttedLine = (AGSPolyline *) [[AGSGeometryEngine defaultGeometryEngine] clipGeometry:geometries[@(targetFloor)] withEnvelope:envelope];
                    if (cuttedLine == nil) {
                        cuttedLine = [self createLineFromCoordinates:@[@[@(lastSnappedTracePoint.x), @(lastSnappedTracePoint.y)], @[@(snappedPoint.x), @(snappedPoint.y)]]];
                    }
                    
                    cuttedLine = (AGSPolyline *) [[AGSGeometryEngine defaultGeometryEngine] simplifyGeometry:cuttedLine];
                    [snappedTraceLineArray addObject:cuttedLine];
                    lastSnappedTracePoint = snappedPoint;
                }
                
                //                NSLog(@"VertexIndex: %d, %d", (int)snappedObject.partIndex, (int)snappedObject.pointIndex);
                //                if (snappedObject.pointIndex != lastSnappedVertexIndex || j == tracePoints.count -1) {
                //                    lastSnappedVertexIndex = (int)snappedObject.pointIndex;
                //                    AGSPoint *snappedTracePoint = [AGSPoint pointWithX:snappedPoint.x y:snappedPoint.y spatialReference:nil];
                //                    [snappedTracePointArray addObject:snappedTracePoint];
                //                    testCount++;
                //                }
                
                if ((snappedObject.partIndex * 1000 + snappedObject.pointIndex) != lastSnappedVertexIndex || j == tracePoints.count -1) {
                    lastSnappedVertexIndex = (int)(snappedObject.partIndex * 1000 + snappedObject.pointIndex);
                    AGSPoint *snappedTracePoint = [AGSPoint pointWithX:snappedPoint.x y:snappedPoint.y spatialReference:nil];
                    [snappedTracePointArray addObject:snappedTracePoint];
                    testCount++;
                }
                
                
                if (originalTracePoint.inTheme) {
                    AGSPoint *themeLocationPoint = [AGSPoint pointWithX:themeLocation.x y:themeLocation.y spatialReference:nil];
                    [snappedTracePointArray addObject:themeLocationPoint];
                    [snappedTraceLineArray addObject:[self createLineFromCoordinates:@[@[@(lastSnappedTracePoint.x), @(lastSnappedTracePoint.y)], @[@(snappedPoint.x), @(snappedPoint.y)]]]];
                    [snappedTraceLineArray addObject:[self createLineFromCoordinates:
                                                      @[@[@(snappedPoint.x), @(snappedPoint.y)],
                                                        @[@(themeLocation.x), @(themeLocation.y)]]]];
                }
            }
            
            for (int k = 0; k < snappedTraceLineArray.count; ++k) {
                [self addGraphic:[AGSGraphic graphicWithGeometry:snappedTraceLineArray[k] symbol:traceSymbol1 attributes:nil]];
                [self addGraphic:[AGSGraphic graphicWithGeometry:snappedTraceLineArray[k] symbol:traceSymbol2 attributes:nil]];
            }
            
            AGSPoint *currentPoint = nil;
            double distanceFilter = 2.0;
            for (int k = 0; k < snappedTracePointArray.count; ++k) {
                AGSPoint *newPoint = snappedTracePointArray[k];
                if ([newPoint distanceToPoint:currentPoint] < distanceFilter) {
                    continue;
                }
                
                currentPoint = newPoint;
                [self addGraphic:[AGSGraphic graphicWithGeometry:snappedTracePointArray[k] symbol:pointSymbol attributes:nil]];
                AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:[NSString stringWithFormat:@"%d", traceIndex + k + 1] color:[UIColor whiteColor]];
                ts.size = CGSizeMake(4, 4);
                [self addGraphic:[AGSGraphic graphicWithGeometry:snappedTracePointArray[k] symbol:ts attributes:nil]];
            }
            NSLog(@"TestCount: %d", testCount);
            NSLog(@"Points: %d", (int)snappedTracePointArray.count);
            NSLog(@"Lines: %d", (int)snappedTraceLineArray.count);
        }
    }
}

- (void)showTraces
{
    NSLog(@"showTraces");
    [self removeAllGraphics];
    
    AGSSimpleMarkerSymbol *firstMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    firstMarkerSymbol.size = CGSizeMake(18, 18);
    firstMarkerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
    firstMarkerSymbol.outline = outlineSymbol;
    
    for (int i = 0; i < traceFloorArray.count; ++i) {
        int traceFloor = [traceFloorArray[i] intValue];
        if (targetFloor == traceFloor) {
            [self addGraphic:[AGSGraphic graphicWithGeometry:traceLineArray[i] symbol:lineSymbol attributes:nil]];
            NSMutableArray *tracePoints = tracePointArray[i];
            int traceIndex = [traceStartIndexArray[i] intValue];
            
            for (int j = 0; j < tracePoints.count; ++j) {
                if (j == 0) {
                    [self addGraphic:[AGSGraphic graphicWithGeometry:tracePoints[j] symbol:firstMarkerSymbol attributes:nil] ];
                } else {
                    [self addGraphic:[AGSGraphic graphicWithGeometry:tracePoints[j] symbol:nil attributes:nil]];
                }
                [self addGraphic:[AGSGraphic graphicWithGeometry:tracePoints[j] symbol:[AGSTextSymbol textSymbolWithText:[NSString stringWithFormat:@"%d", traceIndex + j + 1] color:[UIColor whiteColor]] attributes:nil]];
            }
        }
    }
}

- (void)reset
{
    [self removeAllGraphics];
    
    currentFloor = 0;
    currentStartIndex = 0;
    
    [traceFloorArray removeAllObjects];
    [traceStartIndexArray removeAllObjects];
    [tracePointArray removeAllObjects];
    [traceCoordinateArray removeAllObjects];
    [traceLineArray removeAllObjects];
}

- (void)setPointSymbolWithColor:(UIColor *)color Size:(int)size
{
    pointSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:color];
    pointSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
    pointSymbol.size = CGSizeMake(size, size);
    pointSymbol.outline = outlineSymbol;
    
    [self setRenderer:[AGSSimpleRenderer simpleRendererWithSymbol:pointSymbol]];
}

- (void)setLineSymbolWithColor:(UIColor *)color Width:(float)width
{
    lineSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:color width:width];
}

- (AGSPolyline *)createLineFromCoordinates:(NSArray *)array
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    for (int i = 0; i < array.count; ++i) {
        NSArray *xy = array[i];
        [polyline addPointToPath:[AGSPoint pointWithX:[xy[0] doubleValue] y:[xy[1] doubleValue] spatialReference:self.spatialReference]];
    }
    return polyline;
}

@end
