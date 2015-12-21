//
//  TYFloorLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPFloorLayer.h"
#import "IPMapFileManager.h"
#import "IPEncryption.h"
#import "TYMapEnviroment.h"

@interface IPFloorLayer()
{
    AGSRenderer *floorRender;
    TYRenderingScheme *renderingScheme;
}
@end

@implementation IPFloorLayer

+ (IPFloorLayer *)floorLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[IPFloorLayer alloc] initFloorLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initFloorLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        renderingScheme = aRenderingScheme;
        AGSSimpleFillSymbol *floorSymbol = renderingScheme.defaultFillSymbol;
        floorRender = [[AGSSimpleRenderer alloc] initWithSymbol:floorSymbol];
        self.renderer = floorRender;
    }
    return self;
}

- (void)setRenderingScheme:(TYRenderingScheme *)rs
{
    renderingScheme = rs;
    AGSSimpleFillSymbol *floorSymbol = renderingScheme.defaultFillSymbol;
    floorRender = [[AGSSimpleRenderer alloc] initWithSymbol:floorSymbol];
    self.renderer = floorRender;
}

- (void)loadContents:(AGSFeatureSet *)set
{
    [self removeAllGraphics];
    
    NSArray *allGraphics = set.features;
    [self addGraphics:allGraphics];
}

@end

