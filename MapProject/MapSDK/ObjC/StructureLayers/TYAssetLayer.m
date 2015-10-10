//
//  TYAssetLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYAssetLayer.h"
#import "TYMapFileManager.h"
#import "TYEncryption.h"
#import "TYMapEnviroment.h"

@interface TYAssetLayer()
{
    AGSRenderer *assetRender;
    TYRenderingScheme *renderingScheme;
}

@end

@implementation TYAssetLayer

+ (TYAssetLayer *)assetLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[TYAssetLayer alloc] initAssetLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initAssetLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        renderingScheme = aRenderingScheme;
        assetRender = [self createAssetRender];
        self.renderer = assetRender;
    }
    return self;
}

- (void)setRenderingScheme:(TYRenderingScheme *)rs
{
    renderingScheme = rs;
    assetRender = [self createAssetRender];
    self.renderer = assetRender;
}

- (AGSRenderer *)createAssetRender
{
    AGSUniqueValueRenderer *render = [[AGSUniqueValueRenderer alloc] init];
    NSMutableArray *assetUVs = [[NSMutableArray alloc] init];
    
    NSDictionary *fillSymbolDict = renderingScheme.fillSymbolDictionary;
    NSEnumerator *enumerator = [fillSymbolDict keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        AGSSimpleFillSymbol *sfs = fillSymbolDict[key];
        AGSUniqueValue *uv = [AGSUniqueValue uniqueValueWithValue:[NSString stringWithFormat:@"%@", key] symbol:sfs];
        [assetUVs addObject:uv];
    }
    
    render.uniqueValues = assetUVs;
    render.fields = @[@"COLOR"];
    
    render.defaultSymbol = renderingScheme.defaultFillSymbol;
    
    return render;
}

- (void)loadContents:(AGSFeatureSet *)set
{
    [self removeAllGraphics];
    
    NSArray *allGraphics = set.features;
    [self addGraphics:allGraphics];
}

@end
