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

- (void)loadContentsWithInfo:(TYMapInfo *)info
{
//    NSLog(@"addShopContents");
    [self removeAllGraphics];
    
    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getAssetLayerPath:info];
//    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
//    if ([TYMapEnvironment useEncryption]) {
//        jsonString = [TYEncryption decryptString:jsonString];
//    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        return;
    }
    
    NSString *jsonString;
    
    if ([TYMapEnvironment useEncryption]) {
        jsonString = [TYEncryption descriptFile:fullPath];
    } else {
        jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    }
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    [self addGraphics:allGraphics];
}

@end
