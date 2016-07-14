//
//  TYLabelLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPTextLabelLayer.h"
#import "IPMapFileManager.h"
#import "IPTextLabel.h"
#import "TYMapEnviroment.h"
#import "TYMapType.h"
#import "IPLabelBorderCalculator.h"
#import "IPLabelGroupLayer.h"
#import "TYMapType.h"
#import "IPBrand.h"
#import "IPEncryption.h"

@interface IPTextLabelLayer()
{
    NSMutableArray *allTextLabels;
}
@end

@implementation IPTextLabelLayer

+ (IPTextLabelLayer *)textLabelLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[IPTextLabelLayer alloc] initTextLabelLayerWithSpatialReference:sr];
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
    int currentLevel = [self.groupLayer.mapView getCurrentLevel];
    
    if ([self.groupLayer.mapView isLabelOverlapDetectingEnabled]) {
        for (IPTextLabel *tl in allTextLabels) {
            if (!(currentLevel <= tl.maxLevel && currentLevel >= tl.minLevel)) {
                tl.isHidden = YES;
                continue;
            }
            
            
            CGPoint screenPoint = [self.groupLayer.mapView toScreenPoint:tl.position];
            IPLabelBorder *border = [IPLabelBorderCalculator getTextLabelBorder:tl Point:screenPoint];
            
            BOOL isOverlapping = NO;
            for (IPLabelBorder *visiableBorder in array) {
                if ([IPLabelBorder CheckIntersect:border WithBorder:visiableBorder]) {
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
    } else {
        for (IPTextLabel *tl in allTextLabels) {
            if (currentLevel <= tl.maxLevel && currentLevel >= tl.minLevel) {
                tl.isHidden = NO;
            } else {
                tl.isHidden = YES;
            }
//            tl.isHidden = NO;
        }
    }
}

- (void)updateLabelState
{
    for (IPTextLabel *tl in allTextLabels) {
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

- (void)loadContents:(AGSFeatureSet *)set
{
    [self removeAllGraphics];
    
    [allTextLabels removeAllObjects];
    
    
    NSArray *allGraphics = set.features;
    
    AGSSpatialReference *sr = [TYMapEnvironment defaultSpatialReference];
    TYMapLanguage language = [TYMapEnvironment getMapLanguage];
    
    for (AGSGraphic *graphic in allGraphics) {
        NSString *field = [self getNameFieldForLanguage:language];
        NSString *name = [graphic attributeForKey:field];
        
        int maxLevel = [[graphic attributeForKey:GRAPHIC_ATTRIBUTE_LEVEL_MAX] intValue];
        int minLevel = [[graphic attributeForKey:GRAPHIC_ATTRIBUTE_LEVEL_MIN] intValue];
        
//        NSLog(@"Max-Min: %d-%d", maxLevel, minLevel);


        if (name != nil && name != (id)[NSNull null]) {
            double x = ((AGSPoint *)graphic.geometry).x;
            double y = ((AGSPoint *)graphic.geometry).y;
            AGSPoint *position = (AGSPoint *)[AGSPoint pointWithX:x y:y spatialReference:sr];
            IPTextLabel *textLabel = [[IPTextLabel alloc] initWithName:name Position:position];
            
            if (maxLevel != 0) {
                textLabel.maxLevel = maxLevel;
            }
            
            if (minLevel != 0) {
                textLabel.minLevel = minLevel;
            }
            
//            NSLog(@"Max-Min: %d-%d", textLabel.maxLevel, textLabel.minLevel);
            
            NSString *poiID = [graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID];
            if ([self.brandDict.allKeys containsObject:poiID]) {
                IPBrand *brand = [self.brandDict objectForKey:poiID];
                
                AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:brand.logo];
                pms.size = brand.logoSize;
                
                textLabel.textSymbol = pms;
                textLabel.labelSize = brand.logoSize;
                
            } else {
//                AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:name color:[UIColor blackColor]];
                AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:name color:[UIColor colorWithRed:112/255.0f green:112/255.0f blue:112/255.0f alpha:1.0f]];
                ts.angleAlignment = AGSMarkerSymbolAngleAlignmentScreen;
                ts.hAlignment = AGSTextSymbolHAlignmentCenter;
                ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
                ts.fontSize = 10.0f;
//                ts.color = [UIColor redColor];
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
