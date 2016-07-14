//
//  TYLocationLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/4/2.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPLocationLayer.h"

@interface IPLocationLayer()
{
    AGSMarkerSymbol *locationSymbol;
}

@end


@implementation IPLocationLayer

- (id)initWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        locationSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
        locationSymbol.size = CGSizeMake(5, 5);
        
        AGSSimpleRenderer *renderer = [AGSSimpleRenderer simpleRendererWithSymbol:locationSymbol];
        self.renderer = renderer;
    }
    return self;
}

- (void)setLocationSymbol:(AGSMarkerSymbol *)symbol
{
    locationSymbol = [symbol copy];
    AGSSimpleRenderer *renderer = [AGSSimpleRenderer simpleRendererWithSymbol:locationSymbol];
    self.renderer = renderer;
}

//- (void)showLocation:(AGSPoint *)location
//{
//    [self removeAllGraphics];
//    [self addGraphic:[AGSGraphic graphicWithGeometry:location symbol:locationSymbol attributes:nil]];
//}

- (void)updateDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(TYMapViewMode)mode
{
    locationSymbol.angle = deviceHeading + initAngle;
}

- (void)showLocation:(AGSPoint *)location withDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(TYMapViewMode)mode
{
    [self removeAllGraphics];
    [self addGraphic:[AGSGraphic graphicWithGeometry:location symbol:locationSymbol attributes:nil]];
}

- (void)removeLocation
{
    [self removeAllGraphics];
}

@end
