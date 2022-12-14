//
//  TYRouteLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPRouteLayer.h"
#import "TYMapView.h"
#import "TYMapEnviroment.h"
#import "IPVector2.h"

#import <TYMapData/TYMapData.h>

@interface IPRouteLayer()
{
    AGSSymbol *routeSymbol;
    AGSSymbol *passedSymbol;
}

@end

@implementation IPRouteLayer

+ (IPRouteLayer *)routeLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[IPRouteLayer alloc] initRouteLayerWithSpatialReference:sr];
}

- (id)initRouteLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        routeSymbol = [self createRouteSymbol];
        self.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:routeSymbol];
    }
    return self;
}

- (NSArray *)showRouteResultOnFloor:(int)floor
{
    [self removeAllGraphics];
    
    NSArray *linesToReturn = [self showLinesForRouteResultOnFloor:floor];
    [self showSwitchSymbolForRouteResultOnFloor:floor];
    [self showStartSymbol:self.startPoint];
    [self showEndSymbol:self.endPoint];
    
    return linesToReturn;
}

- (NSArray *)showPassedAndRemainingRouteResultOnFloor:(int)floor WithLocation:(TYLocalPoint *)location
{
    [self removeAllGraphics];
    
    NSArray *linesToReturn = [self showPassedAndRemainingLinesForRouteResultOnFloor:floor WithLocation:location];
    
    [self showSwitchSymbolForRouteResultOnFloor:floor];
    [self showStartSymbol:self.startPoint];
    [self showEndSymbol: self.endPoint];
    
    return linesToReturn;
}

- (NSArray *)showRemainingRouteResultOnFloor:(int)floor WithLocation:(TYLocalPoint *)location
{
    [self removeAllGraphics];
    
    NSArray *linesToReturn = [self showRemainingLinesForRouteResultOnFloor:floor WithLocation:location];
    
    [self showSwitchSymbolForRouteResultOnFloor:floor];
    [self showStartSymbol:self.startPoint];
    [self showEndSymbol: self.endPoint];
    
    return linesToReturn;
}

- (void)showSwitchSymbolForRouteResultOnFloor:(int)floor
{
    if (_routeResult) {
        NSArray *routePartArray = [_routeResult getRoutePartsOnFloor:floor];
        if (routePartArray && routePartArray.count > 0) {
            for (TYRoutePart *rp in routePartArray) {
                if ([rp isFirstPart] && ![rp isLastPart]) {
                    [self addGraphic:[AGSGraphic graphicWithGeometry:[rp getLastPoint] symbol:_switchSymbol attributes:nil]];
                } else if (![rp isFirstPart] && [rp isLastPart]) {
                    [self addGraphic:[AGSGraphic graphicWithGeometry:[rp getFirstPoint] symbol:_switchSymbol attributes:nil]];
                } else if (![rp isFirstPart] && ![rp isLastPart]) {
                    [self addGraphic:[AGSGraphic graphicWithGeometry:[rp getFirstPoint] symbol:_switchSymbol attributes:nil]];
                    [self addGraphic:[AGSGraphic graphicWithGeometry:[rp getLastPoint] symbol:_switchSymbol attributes:nil]];
                }
            }
        }
    }
}

- (NSArray *)showLinesForRouteResultOnFloor:(int)floor
{    NSMutableArray *linesToReturn = [[NSMutableArray alloc] init];
    if (_routeResult) {
        NSArray *routePartArray = [_routeResult getRoutePartsOnFloor:floor];
        if (routePartArray && routePartArray.count > 0) {
            for (TYRoutePart *rp in routePartArray) {
                [self addGraphic:[AGSGraphic graphicWithGeometry:rp.route symbol:nil attributes:nil]];
                [linesToReturn addObject:rp.route];
            }
        }
    }
    return linesToReturn;
}

- (TYRoutePart *)getNearestRoutePartWithLocation:(TYLocalPoint *)location
{
    TYRoutePart *result = nil;
    if (_routeResult) {
        NSArray *routePartArray = [_routeResult getRoutePartsOnFloor:location.floor];
        if (routePartArray && routePartArray.count > 0) {
            double nearestDistance = 10000000;
            
            AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
            AGSPoint *pos = [AGSPoint pointWithX:location.x y:location.y spatialReference:[TYMapEnvironment defaultSpatialReference]];
            for (TYRoutePart *rp in routePartArray) {
                AGSProximityResult *pr = [engine nearestCoordinateInGeometry:rp.route toPoint:pos];
                double distance = [engine distanceFromGeometry:pr.point toGeometry:pos];
                if (distance < nearestDistance) {
                    nearestDistance = distance;
                    result = rp;
                }
            }
        }
    }
    return result;
}

- (NSArray *)showPassedAndRemainingLinesForRouteResultOnFloor:(int)floor WithLocation:(TYLocalPoint *)location
{
    NSMutableArray *linesToReturn = [[NSMutableArray alloc] init];
    TYRoutePart *nearestRoutePart = [self getNearestRoutePartWithLocation:location];

    if (_routeResult) {
        NSArray *routePartArray = [_routeResult getRoutePartsOnFloor:floor];
        if (routePartArray && routePartArray.count > 0) {
            for (TYRoutePart *rp in routePartArray) {
                if (rp == nearestRoutePart) {
                    AGSPolyline *passedLine = [self getPassedLine:rp.route WithPoint:[AGSPoint pointWithX:location.x y:location.y spatialReference:[TYMapEnvironment defaultSpatialReference]]];
                    AGSPolyline *remainingLine = [self getRemainingLine:rp.route WithPoint:[AGSPoint pointWithX:location.x y:location.y spatialReference:[TYMapEnvironment defaultSpatialReference]]];
                    if (passedLine) {
                        [self addGraphic:[AGSGraphic graphicWithGeometry:passedLine symbol:passedSymbol attributes:nil]];
                    }
                    if (remainingLine) {
                        [self addGraphic:[AGSGraphic graphicWithGeometry:remainingLine symbol:nil attributes:nil]];
                    }
                } else {
                    if (rp.partIndex < nearestRoutePart.partIndex) {
                        [self addGraphic:[AGSGraphic graphicWithGeometry:rp.route symbol:passedSymbol attributes:nil]];
                    } else {
                        [self addGraphic:[AGSGraphic graphicWithGeometry:rp.route symbol:nil attributes:nil]];
                    }
                }
                [linesToReturn addObject:rp.route];
            }
        }
    }
    return linesToReturn;
}

- (NSArray *)showRemainingLinesForRouteResultOnFloor:(int)floor WithLocation:(TYLocalPoint *)location
{
    NSMutableArray *linesToReturn = [[NSMutableArray alloc] init];
    TYRoutePart *nearestRoutePart = [self getNearestRoutePartWithLocation:location];
    
    if (_routeResult) {
        NSArray *routePartArray = [_routeResult getRoutePartsOnFloor:floor];
        if (routePartArray && routePartArray.count > 0) {
            for (TYRoutePart *rp in routePartArray) {
                if (rp == nearestRoutePart) {
                    AGSPolyline *remainingLine = [self getRemainingLine:rp.route WithPoint:[AGSPoint pointWithX:location.x y:location.y spatialReference:[TYMapEnvironment defaultSpatialReference]]];
                    if (remainingLine) {
                        [self addGraphic:[AGSGraphic graphicWithGeometry:remainingLine symbol:nil attributes:nil]];
                        [linesToReturn addObject:remainingLine];
                    }
                } else {
                    [self addGraphic:[AGSGraphic graphicWithGeometry:rp.route symbol:nil attributes:nil]];
                    [linesToReturn addObject:rp.route];
                }
            }
        }
    }
    return linesToReturn;
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
    
    if (cuttedLineArray.count == 0) {
        return originalLine;
    }
    
    for (AGSPolyline *line in cuttedLineArray) {
        BOOL isLastHalf = [engine geometry:line touchesGeometry:lastPoint];
        if (isLastHalf) {
            result = line;
        }
    }
    return result;
}

- (AGSPolyline *)getPassedLine:(AGSPolyline *)originalLine WithPoint:(AGSPoint *)point
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
    
    if (cuttedLineArray.count == 0) {
        return nil;
    }
    
    for (AGSPolyline *line in cuttedLineArray) {
        BOOL isLastHalf = [engine geometry:line touchesGeometry:lastPoint];
        if (!isLastHalf) {
            result = line;
        }
    }
    return result;
}

- (void)reset
{
    _routeResult = nil;
    _startPoint = nil;
    _endPoint = nil;
    [self removeAllGraphics];
}

- (AGSSymbol *)createRouteSymbol
{
    {
        AGSCompositeSymbol *passedCS = [AGSCompositeSymbol compositeSymbol];
        
        AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
        sls1.color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        sls1.style = AGSSimpleLineSymbolStyleSolid;
        sls1.width = 9;
        [passedCS addSymbol:sls1];
        
        AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
        sls2.color = [UIColor colorWithRed:30/255.0f green:255/255.0f blue:0 alpha:1.0f];
        sls2.style = AGSSimpleLineSymbolStyleSolid;
        sls2.width = 6;
        [passedCS addSymbol:sls2];
        
        passedSymbol = passedCS;
    }
    
    
    
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

- (void)showStartSymbol:(TYLocalPoint *)sp
{
    if (sp && sp.floor == self.mapView.currentMapInfo.floorNumber) {
        [self addGraphic:[AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:sp.x y:sp.y spatialReference:self.mapView.spatialReference] symbol:_startSymbol attributes:nil]];
    }
}

- (void)showEndSymbol:(TYLocalPoint *)ep
{
    if (ep && ep.floor == self.mapView.currentMapInfo.floorNumber) {
        [self addGraphic:[AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:ep.x y:ep.y spatialReference:self.mapView.spatialReference] symbol:_endSymbol attributes:nil]];
    }
}

- (void)showSwitchSymbol:(TYLocalPoint *)sp
{
    if (sp && sp.floor == self.mapView.currentMapInfo.floorNumber) {
        [self addGraphic:[AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:sp.x y:sp.y spatialReference:self.mapView.spatialReference] symbol:_switchSymbol attributes:nil]];
    }
}

@end

