//
//  NPRouteHintLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteHintLayer.h"
#import "NPMapEnviroment.h"

@interface NPRouteHintLayer()
{
    AGSSymbol *routeHintSymbol;
}

@end

@implementation NPRouteHintLayer

+ (NPRouteHintLayer *)routeHintLayerWithSpatialReference:(NPSpatialReference *)sr
{
    return [[NPRouteHintLayer alloc] initRouteHintLayerWithSpatialReference:sr];
}

- (id)initRouteHintLayerWithSpatialReference:(NPSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        routeHintSymbol = [self createRouteHintSymbol];
        self.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:routeHintSymbol];
    }
    return self;
}

- (void)showRouteHint:(AGSPolyline *)line
{
    [self removeAllGraphics];
    [self addGraphic:[AGSGraphic graphicWithGeometry:line symbol:nil attributes:nil]];
}

- (AGSSymbol *)createRouteHintSymbol
{
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 8;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor colorWithRed:30/255.0f green:255/255.0f blue:0 alpha:1.0f];
    sls2.style = AGSSimpleLineSymbolStyleSolid;
    sls2.width = 6;
    [cs addSymbol:sls2];
    
    return cs;
}

@end
