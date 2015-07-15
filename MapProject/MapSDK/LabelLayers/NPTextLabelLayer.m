//
//  NPLabelLayer.m
//  MapProject
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
#import "NPMapType.h"
#import "NPBrand.h"
//#import "NPMapView.h"

@interface NPTextLabelLayer()
{
    NSMutableArray *allTextLabels;
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
    }
    return self;
}

- (void)displayLabels:(NSMutableArray *)array
{
    [self calculateLabelBorders:array];
    [self updateLabelState];
}

- (void)calculateLabelBorders:(NSMutableArray *)array
{
    for (NPTextLabel *tl in allTextLabels) {
        CGPoint screenPoint = [self.groupLayer.mapView toScreenPoint:tl.position];
        NPLabelBorder *border = [NPLabelBorderCalculator getTextLabelBorder:tl Point:screenPoint];
        
        BOOL isOverlapping = NO;
        for (NPLabelBorder *visiableBorder in array) {
            if ([NPLabelBorder CheckIntersect:border WithBorder:visiableBorder]) {
                isOverlapping = YES;
                break;
            }
        }
        
        if (isOverlapping) {
            tl.isHidden = YES;
        } else {
            tl.isHidden = NO;
            [array addObject:border];
        }
        
    }
}

- (void)updateLabelState
{
    for (NPTextLabel *tl in allTextLabels) {
        if (tl.isHidden) {
            tl.textGraphic.symbol = nil;
        } else {
            tl.textGraphic.symbol = tl.textSymbol;
        }
    }
}

- (NSString *)getNameFieldForLanguage:(NPMapLanguage)l
{
    NSString *result = nil;
    switch (l) {
        case NPSimplifiedChinese:
        result = NAME_FIELD_SIMPLIFIED_CHINESE;
        break;
        
        case NPTraditionalChinese:
        result = NAME_FIELD_TRADITIONAL_CHINESE;
        break;
        
        case NPEnglish:
        result = NAME_FIELD_ENGLISH;
        break;
        
        default:
        result = NAME_FIELD_SIMPLIFIED_CHINESE;
        break;
    }
    return result;
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
    
    TYSpatialReference *sr = [NPMapEnvironment defaultSpatialReference];
    NPMapLanguage language = [NPMapEnvironment getMapLanguage];
    
    for (AGSGraphic *graphic in allGraphics) {
        NSString *field = [self getNameFieldForLanguage:language];
        NSString *name = [graphic attributeForKey:field];
        
        if (name != nil && name != (id)[NSNull null]) {
            double x = ((AGSPoint *)graphic.geometry).x;
            double y = ((AGSPoint *)graphic.geometry).y;
            TYPoint *position = (TYPoint *)[AGSPoint pointWithX:x y:y spatialReference:sr];
            NPTextLabel *textLabel = [[NPTextLabel alloc] initWithName:name Position:position];

            NSString *poiID = [graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID];
            if ([self.brandDict.allKeys containsObject:poiID]) {
                NPBrand *brand = [self.brandDict objectForKey:poiID];
                
                AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:brand.logo];
                pms.size = brand.logoSize;
                
                textLabel.textSymbol = pms;
                textLabel.labelSize = brand.logoSize;
                
            } else {
                AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:name color:[UIColor blackColor]];
                ts.angleAlignment = AGSMarkerSymbolAngleAlignmentScreen;
                ts.hAlignment = AGSTextSymbolHAlignmentCenter;
                ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
                ts.fontSize = 10.0f;
                ts.fontFamily = @"Heiti SC";
                textLabel.textSymbol = ts;
            }
            
            textLabel.textGraphic = graphic;
            [self addGraphic:textLabel.textGraphic];
            [allTextLabels addObject:textLabel];
        }
    }
}

- (BOOL)updateRoomLabel:(NSString *)pid WithName:(NSString *)name
{
    NSArray *graphicArray = self.graphics;
    
    NPMapLanguage language = [NPMapEnvironment getMapLanguage];
    NSString *field = [self getNameFieldForLanguage:language];

    for (AGSGraphic *g in graphicArray) {
        NSString *poiID = [g attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID];
        if ([poiID isEqualToString:pid]) {
            [g setAttribute:name forKey:field];
            return YES;
        }
    }
    return NO;
}

- (AGSFeatureSet *)getFeatureSet
{
    NSArray *graphicArray = self.graphics;
    AGSFeatureSet *set = [AGSFeatureSet featureSetWithFeatures:graphicArray];
    return set;
}

@end
