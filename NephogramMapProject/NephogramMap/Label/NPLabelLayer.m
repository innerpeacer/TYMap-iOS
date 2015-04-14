//
//  NPLabelLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPLabelLayer.h"
#import "NPMapFileManager.h"

@implementation NPLabelLayer

+ (NPLabelLayer *)labelLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[NPLabelLayer alloc] initLabelLayerWithSpatialReference:sr];
}

- (id)initLabelLayerWithSpatialReference:(AGSSpatialReference *)sr
{
//    self = [super initWithSpatialReference:sr];
    self = [super initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    if (self) {

    }
    return self;
}

- (void)loadContentsWithInfo:(NPMapInfo *)info;
{
//    NSLog(@"addLabelContents");
    [self removeAllGraphics];
    
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getLabelLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    for (AGSGraphic *g in allGraphics) {
        NSString *name = [g attributeForKey:@"NAME"];
        
        if (name != nil && name != (id)[NSNull null]) {
            AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:name color:[UIColor blackColor]];
            ts.angleAlignment = AGSMarkerSymbolAngleAlignmentScreen;
            ts.fontSize = 10.0f;
            ts.fontFamily = @"Heiti SC";
            g.symbol = ts;
            
            [self addGraphic:g];
        }
    }
    
}

@end
