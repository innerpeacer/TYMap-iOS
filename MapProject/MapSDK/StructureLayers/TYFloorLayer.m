//
//  TYFloorLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYFloorLayer.h"
#import "TYMapFileManager.h"
#import "TYEncryption.h"
#import "TYMapEnviroment.h"

@interface TYFloorLayer()
{
    AGSRenderer *floorRender;
    TYRenderingScheme *renderingScheme;
}
@end

@implementation TYFloorLayer

+ (TYFloorLayer *)floorLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[TYFloorLayer alloc] initFloorLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
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

