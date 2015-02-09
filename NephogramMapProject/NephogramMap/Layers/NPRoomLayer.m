//
//  NPRoomLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRoomLayer.h"

@interface NPRoomLayer()
{
    AGSRenderer *roomRender;
    
    NPRenderingScheme *renderingScheme;
}

@end

@implementation NPRoomLayer

+ (NPRoomLayer *)roomLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[NPRoomLayer alloc] initRoomLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initRoomLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        renderingScheme = aRenderingScheme;
        roomRender = [self createRoomRender];
        self.renderer = roomRender;
    }
    return self;
}

- (AGSRenderer *)createRoomRender
{
    AGSUniqueValueRenderer *render = [[AGSUniqueValueRenderer alloc] init];
    NSMutableArray *roomUVs = [[NSMutableArray alloc] init];
    
    NSDictionary *fillSymbolDict = renderingScheme.fillSymbolDictionary;
    
    NSEnumerator *enumerator = [fillSymbolDict keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        AGSSimpleFillSymbol *sfs = fillSymbolDict[key];
        AGSUniqueValue *uv = [AGSUniqueValue uniqueValueWithValue:[NSString stringWithFormat:@"%@", key] symbol:sfs];
        [roomUVs addObject:uv];
    }
    
    render.uniqueValues = roomUVs;
    render.fields = @[@"COLOR"];
    
    render.defaultSymbol = renderingScheme.defaultFillSymbol;
    
    return render;
}

- (void)loadContentsWithInfo:(NPMapInfo *)info
{
    NSLog(@"addRoomContents");
    [self removeAllGraphics];
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_ROOM",info.mapID] ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    [self addGraphics:allGraphics];
}

@end

