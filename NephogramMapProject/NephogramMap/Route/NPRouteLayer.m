//
//  NPRouteLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteLayer.h"

@interface NPRouteLayer()
{
    AGSSymbol *routeSymbol;
}

@end

@implementation NPRouteLayer

+ (NPRouteLayer *)routeLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[NPRouteLayer alloc] initRouteLayerWithSpatialReference:sr];
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

- (AGSSymbol *)createRouteSymbol
{
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor yellowColor];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 8;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor blueColor];
    sls2.style = AGSSimpleLineSymbolStyleSolid;
    sls2.width = 4;
    [cs addSymbol:sls2];
    
    return cs;
}

@end

