//
//  NPLabelLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPTextLabelLayer.h"
#import "NPMapFileManager.h"
#import "NPTextLabel.h"
#import "NPMapEnviroment.h"
#import "NPMapType.h"
#import "NPLabelBorderCalculator.h"
#import "NPLabelGroupLayer.h"

@interface NPTextLabelLayer()
{
    NSMutableArray *allTextLabels;
    
    NSMutableArray *visiableBorders;
}
@end

@implementation NPTextLabelLayer

+ (NPTextLabelLayer *)textLabelLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[NPTextLabelLayer alloc] initTextLabelLayerWithSpatialReference:sr];
}

- (id)initTextLabelLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    if (self) {
        allTextLabels = [[NSMutableArray alloc] init];
        visiableBorders = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updateLabels
{
//    NSLog(@"NPTextLabelLayer updateLabels");
    
    [visiableBorders removeAllObjects];
    for (NPTextLabel *tl in allTextLabels) {
        CGPoint screenPoint = [self.groupLayer.mapView toScreenPoint:tl.position];
        NPLabelBorder *border = [NPLabelBorderCalculator getTextLabelBorder:tl Point:screenPoint];
        
        BOOL isOverlapping = NO;
        for (NPLabelBorder *visiableBorder in visiableBorders) {
            if ([NPLabelBorder CheckIntersect:border WithBorder:visiableBorder]) {
                isOverlapping = YES;
                break;
            }
        }
        
        if (isOverlapping) {
            tl.textGraphic.symbol = nil;
        } else {
            tl.textGraphic.symbol = tl.textSymbol;
            [visiableBorders addObject:border];
        }
        
    }
}

- (void)loadContentsWithInfo:(NPMapInfo *)info;
{
    [self removeAllGraphics];
    
    [allTextLabels removeAllObjects];
    
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getLabelLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    NPSpatialReference *sr = [NPMapEnvironment defaultSpatialReference];
    
    for (AGSGraphic *graphic in allGraphics) {
        NSString *name = [graphic attributeForKey:@"NAME"];
        
        if (name != nil && name != (id)[NSNull null]) {
            double x = ((AGSPoint *)graphic.geometry).x;
            double y = ((AGSPoint *)graphic.geometry).y;
            NPPoint *position = (NPPoint *)[AGSPoint pointWithX:x y:y spatialReference:sr];
            
//            NPTextLabel *textLabel = [[NPTextLabel alloc] initWithGeoID:gid PoiID:pid Name:name Position:position switchignWidth:width];
            NPTextLabel *textLabel = [[NPTextLabel alloc] initWithName:name Position:position];

            
            AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:name color:[UIColor blackColor]];
            ts.angleAlignment = AGSMarkerSymbolAngleAlignmentScreen;
            ts.hAlignment = AGSTextSymbolHAlignmentCenter;
            ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
            ts.fontSize = 10.0f;
            ts.fontFamily = @"Heiti SC";
            textLabel.textSymbol = ts;
            
            textLabel.textGraphic = graphic;
            [self addGraphic:textLabel.textGraphic];
            [allTextLabels addObject:textLabel];
        }
    }
    
}

@end
