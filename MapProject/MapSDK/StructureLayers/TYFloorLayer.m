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

- (void)loadContentsWithInfo:(TYMapInfo *)info
{
//    NSLog(@"addFloorContent");
    
    [self removeAllGraphics];
    
    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getFloorLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    if ([TYMapEnvironment useEncryption]) {
        jsonString = [TYEncryption decryptString:jsonString];
    }
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    for (AGSGraphic *graphic in allGraphics) {
        [self addGraphic:graphic];
    }
    
}

@end

