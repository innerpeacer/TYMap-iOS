//
//  NPFloorLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPFloorLayer.h"
#import "NPMapFileManager.h"

@interface NPFloorLayer()
{
    AGSRenderer *floorRender;
    NPRenderingScheme *renderingScheme;
}
@end

@implementation NPFloorLayer

+ (NPFloorLayer *)floorLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[NPFloorLayer alloc] initFloorLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initFloorLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
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

- (void)loadContentsWithInfo:(NPMapInfo *)info
{
//    NSLog(@"addFloorContent");
    
    [self removeAllGraphics];
    
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getFloorLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    for (AGSGraphic *graphic in allGraphics) {
        [self addGraphic:graphic];
    }
    
}

@end

