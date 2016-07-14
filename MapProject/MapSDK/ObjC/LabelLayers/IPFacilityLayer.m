//
//  TYFacilityLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPFacilityLayer.h"
#import "TYMapType.h"
#import "IPMapFileManager.h"
#import "IPFacilityLabel.h"
#import "TYMapView.h"
#import "IPLabelGroupLayer.h"
#import "IPLabelBorder.h"
#import "IPLabelBorderCalculator.h"
#import "TYMapEnviroment.h"
#import "IPEncryption.h"

@interface IPFacilityLayer()
{
    NSMutableDictionary *allFacilitySymbols;
    NSMutableDictionary *allHighlightFacilitySymbols;
    
    NSMutableDictionary *groupedFacilityLabelDict;
    NSMutableDictionary *facilityLabelDict;
    
    TYRenderingScheme *renderingScheme;
}

@end

@implementation IPFacilityLayer

+ (IPFacilityLayer *)facilityLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[IPFacilityLayer alloc] initFacilityLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

+ (IPFacilityLayer *)facilityLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[IPFacilityLayer alloc] initFacilityLayerWithSpatialReference:sr];
}


- (id)initFacilityLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    if (self) {
        allFacilitySymbols = [[NSMutableDictionary alloc] init];
        allHighlightFacilitySymbols = [[NSMutableDictionary alloc] init];
        
        groupedFacilityLabelDict = [[NSMutableDictionary alloc] init];
        facilityLabelDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initFacilityLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithFullEnvelope:nil renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    if (self) {
        renderingScheme = aRenderingScheme;
        
        allFacilitySymbols = [[NSMutableDictionary alloc] init];
        allHighlightFacilitySymbols = [[NSMutableDictionary alloc] init];
        [self getFacilitySymbols];
        
        groupedFacilityLabelDict = [[NSMutableDictionary alloc] init];
        facilityLabelDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setRenderingScheme:(TYRenderingScheme *)rs
{
    renderingScheme = rs;
    
    allFacilitySymbols = [[NSMutableDictionary alloc] init];
    allHighlightFacilitySymbols = [[NSMutableDictionary alloc] init];
    [self getFacilitySymbols];
}

- (void)getFacilitySymbols
{
    NSDictionary *iconDict = renderingScheme.iconSymbolDictionary;
    NSEnumerator *enumerator = [iconDict keyEnumerator];

    id key;
    while ((key = [enumerator nextObject])) {
        NSString *icon = iconDict[key];
        
        NSString *noramlIcon = [NSString stringWithFormat:@"%@_normal", icon];
        AGSPictureMarkerSymbol *normalPms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:noramlIcon];
        normalPms.size = CGSizeMake(26, 26);
        [allFacilitySymbols setObject:normalPms forKey:key];
        
        NSString *highlightedIcon = [NSString stringWithFormat:@"%@_highlighted", icon];
        AGSPictureMarkerSymbol *highlightedPms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:highlightedIcon];
        highlightedPms.size = CGSizeMake(26, 26);
        [allHighlightFacilitySymbols setObject:highlightedPms forKey:key];
    }
}

- (void)updateLabels:(NSMutableArray *)array
{
    [self updateLabelBorders:array];
    [self updateLabelState];
}

- (void)updateLabelBorders:(NSMutableArray *)array
{
    if ([self.groupLayer.mapView isLabelOverlapDetectingEnabled]) {
        for (IPFacilityLabel *fl in facilityLabelDict.allValues) {
            CGPoint screenPoint = [self.groupLayer.mapView toScreenPoint:fl.position];
            IPLabelBorder *border = [IPLabelBorderCalculator getFacilityLabelBorder:screenPoint];
            
            BOOL isOverlapping = NO;
            
            for (IPLabelBorder *visiableBorder in array) {
                if ([IPLabelBorder CheckIntersect:border WithBorder:visiableBorder]) {
                    isOverlapping = YES;
                    break;
                }
            }
            
            if (isOverlapping) {
                fl.isHidden = YES;
            } else {
                fl.isHidden = NO;
                [array addObject:border];
            }
        }
    } else {
        for (IPFacilityLabel *fl in facilityLabelDict.allValues) {
            fl.isHidden = NO;
        }
    }
}

- (void)updateLabelState
{
    for (IPFacilityLabel *fl in facilityLabelDict.allValues) {
        if (fl.isHidden) {
            fl.facilityGraphic.symbol = nil;
        } else {
            fl.facilityGraphic.symbol = fl.currentSymbol;
        }
    }
}

- (void)loadContents:(AGSFeatureSet *)set
{
    [self removeAllGraphics];
    
    [groupedFacilityLabelDict removeAllObjects];
    [facilityLabelDict removeAllObjects];

    NSArray *allGraphics = set.features;
    
    for (AGSGraphic *graphic in allGraphics) {
        id categoryIDObject = [graphic attributeForKey:@"COLOR"];
        if ([categoryIDObject isKindOfClass:[NSNull class]]) {
            continue;
        }
        int categoryID = [[graphic attributeForKey:@"COLOR"] intValue];
        AGSPoint *pos = (AGSPoint *)graphic.geometry;
        
        if (![groupedFacilityLabelDict.allKeys containsObject:@(categoryID)]) {
            NSMutableArray *array = [NSMutableArray array];
            [groupedFacilityLabelDict setObject:array forKey:@(categoryID)];
        }
        
        IPFacilityLabel *fLabel = [[IPFacilityLabel alloc] initWithCategoryID:categoryID Position:pos];
        fLabel.facilityGraphic = graphic;
        fLabel.normalFacilitySymbol = [allFacilitySymbols objectForKey:@(categoryID)];
        fLabel.highlightedFacilitySymbol = [allHighlightFacilitySymbols objectForKey:@(categoryID)];
        [fLabel setHighlighted:NO];
        
        
        NSMutableArray *array = groupedFacilityLabelDict[@(categoryID)];
        [array addObject:fLabel];
        
        NSString *poiID = [graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID];
        [facilityLabelDict setObject:fLabel forKey:poiID];
    }
    
    [self addGraphics:allGraphics];
}


- (void)showFacilityWithCategory:(int)categoryID
{
    NSEnumerator *enumerator = [groupedFacilityLabelDict keyEnumerator];
    
    id key;
    while ((key = [enumerator nextObject])) {
        NSArray *array = groupedFacilityLabelDict[key];
        if ([key intValue] == categoryID) {
            for (IPFacilityLabel *fl in array) {
                fl.currentSymbol = fl.highlightedFacilitySymbol;
            }
        } else {
            for (IPFacilityLabel *fl in array) {
                fl.currentSymbol = fl.normalFacilitySymbol;
            }
        }
    }
    
    [self updateLabelState];
}

- (void)showAllFacilities
{
    for (NSArray *array in groupedFacilityLabelDict.allValues) {
        for (IPFacilityLabel *fl in array) {
            fl.currentSymbol = fl.normalFacilitySymbol;
        }
    }
    
    [self updateLabelState];
}

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs
{
    NSEnumerator *enumerator = [groupedFacilityLabelDict keyEnumerator];
    
    id key;
    while ((key = [enumerator nextObject])) {
        NSArray *array = groupedFacilityLabelDict[key];
        
        if ([categoryIDs containsObject:key]) {
            for (IPFacilityLabel *fl in array) {
                fl.currentSymbol = fl.highlightedFacilitySymbol;
            }
        } else {
            for (IPFacilityLabel *fl in array) {
                fl.currentSymbol = fl.normalFacilitySymbol;
            }
        }
    }
    
    [self updateLabelState];
}

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor
{
    return [groupedFacilityLabelDict allKeys];

}

- (TYPoi *)getPoiWithPoiID:(NSString *)pid
{
    TYPoi *result = nil;
    IPFacilityLabel *fl = [facilityLabelDict objectForKey:pid];
    AGSGraphic *graphic = fl.facilityGraphic;

    if (graphic) {
        result = [TYPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_FACILITY];
    }
    return result;
}

- (void)highlightPoi:(NSString *)poiID
{
    IPFacilityLabel *fl = [facilityLabelDict objectForKey:poiID];
    fl.currentSymbol = fl.highlightedFacilitySymbol;
    
    [self updateLabelState];
}

@end
