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

- (void)showRouteResultFloor:(int)floor
{
    [self removeAllGraphics];
    if (_routeResult) {
        
        AGSPolyline *line = [_routeResult getRouteOnFloor:floor];
        if (line) {
            [self addGraphic:[NPGraphic graphicWithGeometry:line symbol:nil attributes:nil]];
            
            if ([_routeResult isFirstFloor:floor] && [_routeResult isLastFloor:floor]) {
                NSLog(@"Same Floor");
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
    sls1.color = [UIColor colorWithRed:173/255.0f green:8/255.0f blue:8/255.0f alpha:1.0f];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 7;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor colorWithRed:255/255.0f green:38/255.0f blue:38/255.0f alpha:1.0f];
    sls2.style = AGSSimpleLineSymbolStyleSolid;
    sls2.width = 6;
    [cs addSymbol:sls2];
    
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    [cs addSymbol:sms];
    
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

