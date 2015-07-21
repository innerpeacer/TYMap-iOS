//
//  TYLabelLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYTextLabelLayer.h"
#import "TYMapFileManager.h"
#import "TYTextLabel.h"
#import "TYMapEnviroment.h"
#import "TYMapType.h"
#import "TYLabelBorderCalculator.h"
#import "TYLabelGroupLayer.h"
#import "TYMapType.h"
#import "TYBrand.h"
#import "TYEncryption.h"

@interface TYTextLabelLayer()
{
    NSMutableArray *allTextLabels;
}
@end

@implementation TYTextLabelLayer

+ (TYTextLabelLayer *)textLabelLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[TYTextLabelLayer alloc] initTextLabelLayerWithSpatialReference:sr];
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
    for (TYTextLabel *tl in allTextLabels) {
        CGPoint screenPoint = [self.groupLayer.mapView toScreenPoint:tl.position];
        TYLabelBorder *border = [TYLabelBorderCalculator getTextLabelBorder:tl Point:screenPoint];
        
        BOOL isOverlapping = NO;
        for (TYLabelBorder *visiableBorder in array) {
            if ([TYLabelBorder CheckIntersect:border WithBorder:visiableBorder]) {
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
    for (TYTextLabel *tl in allTextLabels) {
        if (tl.isHidden) {
            tl.textGraphic.symbol = nil;
        } else {
            tl.textGraphic.symbol = tl.textSymbol;
        }
    }
}

- (NSString *)getNameFieldForLanguage:(TYMapLanguage)l
{
    NSString *result = nil;
    switch (l) {
        case TYSimplifiedChinese:
        result = NAME_FIELD_SIMPLIFIED_CHINESE;
        break;
        
        case TYTraditionalChinese:
        result = NAME_FIELD_TRADITIONAL_CHINESE;
        break;
        
        case TYEnglish:
        result = NAME_FIELD_ENGLISH;
        break;
        
        default:
        result = NAME_FIELD_SIMPLIFIED_CHINESE;
        break;
    }
    return result;
}

- (void)loadContentsWithInfo:(TYMapInfo *)info;
{
    [self removeAllGraphics];
    
    [allTextLabels removeAllObjects];
    
    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getLabelLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    if ([TYMapEnvironment useEncryption]) {
        jsonString = [TYEncryption decryptString:jsonString];
    }
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    TYSpatialReference *sr = [TYMapEnvironment defaultSpatialReference];
    TYMapLanguage language = [TYMapEnvironment getMapLanguage];
    
    for (AGSGraphic *graphic in allGraphics) {
        NSString *field = [self getNameFieldForLanguage:language];
        NSString *name = [graphic attributeForKey:field];
        
        if (name != nil && name != (id)[NSNull null]) {
            double x = ((AGSPoint *)graphic.geometry).x;
            double y = ((AGSPoint *)graphic.geometry).y;
            TYPoint *position = (TYPoint *)[AGSPoint pointWithX:x y:y spatialReference:sr];
            TYTextLabel *textLabel = [[TYTextLabel alloc] initWithName:name Position:position];

            NSString *poiID = [graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID];
            if ([self.brandDict.allKeys containsObject:poiID]) {
                TYBrand *brand = [self.brandDict objectForKey:poiID];
                
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
    
    TYMapLanguage language = [TYMapEnvironment getMapLanguage];
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
