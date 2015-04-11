//
//  NPAssetLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPAssetLayer.h"
#import "NPMapFileManager.h"

@interface NPAssetLayer()
{
    AGSRenderer *assetRender;
    NPRenderingScheme *renderingScheme;
}

@end

@implementation NPAssetLayer

+ (NPAssetLayer *)assetLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[NPAssetLayer alloc] initAssetLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initAssetLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        renderingScheme = aRenderingScheme;
        assetRender = [self createAssetRender];
        self.renderer = assetRender;
    }
    return self;
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

- (void)loadContentsWithInfo:(NPMapInfo *)info
{
//    NSLog(@"addShopContents");
    [self removeAllGraphics];
    
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getAssetLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    [self addGraphics:allGraphics];
}

@end
