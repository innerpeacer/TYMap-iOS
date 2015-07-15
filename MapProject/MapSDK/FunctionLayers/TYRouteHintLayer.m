//
//  TYRouteHintLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYRouteHintLayer.h"
#import "NPMapEnviroment.h"
#import "Vector2.h"

@interface TYRouteHintLayer()
{
    AGSSymbol *routeHintSymbol;
}

@end

@implementation TYRouteHintLayer

+ (TYRouteHintLayer *)routeHintLayerWithSpatialReference:(TYSpatialReference *)sr
{
    return [[TYRouteHintLayer alloc] initRouteHintLayerWithSpatialReference:sr];
}

- (id)initRouteHintLayerWithSpatialReference:(TYSpatialReference *)sr
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
    
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeHintArrow"];
    
    AGSPoint *start = [line pointOnPath:0 atIndex:0];
    AGSPoint *end = [line pointOnPath:0 atIndex:line.numPoints - 1];
    
    Vector2 *v = [[Vector2 alloc] init];
    v.x = end.x - start.x;
    v.y = end.y - start.y;
    
    pms.angle = [v getAngle];
    
    [self addGraphic:[AGSGraphic graphicWithGeometry:[line pointOnPath:0 atIndex:0] symbol:pms attributes:nil]];
    [self addGraphic:[AGSGraphic graphicWithGeometry:[line pointOnPath:0 atIndex:line.numPoints - 1] symbol:pms attributes:nil]];

}

- (AGSSymbol *)createRouteHintSymbol
{
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 9;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor colorWithRed:30/255.0f green:255/255.0f blue:0 alpha:1.0f];
    sls2.style = AGSSimpleLineSymbolStyleSolid;
    sls2.width = 6;
    [cs addSymbol:sls2];
    
    return cs;
}

@end
