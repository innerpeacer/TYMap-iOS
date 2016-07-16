//
//  IPShadeLayer.m
//  MapProject
//
//  Created by innerpeacer on 16/7/15.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "IPShadeLayer.h"
#import "TYMapType.h"

@interface IPShadeLayer()
{
    AGSRenderer *shadeRender;
    TYRenderingScheme *renderingScheme;
}

@end

@implementation IPShadeLayer

+ (IPShadeLayer *)shadeLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[IPShadeLayer alloc] initShadeLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

+ (IPShadeLayer *)shadeLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[IPShadeLayer alloc] initShadeLayerWithSpatialReference:sr];
}

- (id)initShadeLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {

    }
    return self;
}

- (id)initShadeLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        renderingScheme = aRenderingScheme;
        shadeRender = [self createShadeRender];
        self.renderer = shadeRender;
    }
    return self;
}

- (void)loadContents:(AGSFeatureSet *)set
{
    [self removeAllGraphics];
    NSArray *allGraphics = set.features;
    [self addGraphics:allGraphics];
}


- (void)setRenderingScheme:(TYRenderingScheme *)rs
{
    renderingScheme = rs;
    shadeRender = [self createShadeRender];
    self.renderer = shadeRender;
}

- (AGSRenderer *)createShadeRender
{
    AGSUniqueValueRenderer *render = [[AGSUniqueValueRenderer alloc] init];
    NSMutableArray *shadeUVs = [[NSMutableArray alloc] init];
    
    NSDictionary *fillSymbolDict = renderingScheme.fillSymbolDictionary;
    
    NSEnumerator *enumerator = [fillSymbolDict keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        AGSSimpleFillSymbol *sfs = fillSymbolDict[key];
        AGSUniqueValue *uv = [AGSUniqueValue uniqueValueWithValue:[NSString stringWithFormat:@"%@", key] symbol:sfs];
        [shadeUVs addObject:uv];
    }
    
    render.uniqueValues = shadeUVs;
    render.fields = @[@"COLOR"];
    
    render.defaultSymbol = renderingScheme.defaultFillSymbol;
    
    return render;
}

@end
