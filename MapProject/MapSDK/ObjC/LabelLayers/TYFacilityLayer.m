//
//  TYFacilityLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYFacilityLayer.h"
#import "TYMapType.h"
#import "TYMapFileManager.h"
#import "TYFacilityLabel.h"
#import "TYMapView.h"
#import "TYLabelGroupLayer.h"
#import "TYLabelBorder.h"
#import "TYLabelBorderCalculator.h"
#import "TYMapEnviroment.h"
#import "TYEncryption.h"

@interface TYFacilityLayer()
{
    NSMutableDictionary *allFacilitySymbols;
    NSMutableDictionary *allHighlightFacilitySymbols;
    
    NSMutableDictionary *groupedFacilityLabelDict;
    NSMutableDictionary *facilityLabelDict;
    
    TYRenderingScheme *renderingScheme;
}

@end

@implementation TYFacilityLayer

+ (TYFacilityLayer *)facilityLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[TYFacilityLayer alloc] initFacilityLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
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
        for (TYFacilityLabel *fl in facilityLabelDict.allValues) {
            CGPoint screenPoint = [self.groupLayer.mapView toScreenPoint:fl.position];
            TYLabelBorder *border = [TYLabelBorderCalculator getFacilityLabelBorder:screenPoint];
            
            BOOL isOverlapping = NO;
            
            for (TYLabelBorder *visiableBorder in array) {
                if ([TYLabelBorder CheckIntersect:border WithBorder:visiableBorder]) {
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
        for (TYFacilityLabel *fl in facilityLabelDict.allValues) {
            fl.isHidden = NO;
        }
    }
}

- (void)updateLabelState
{
    for (TYFacilityLabel *fl in facilityLabelDict.allValues) {
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
        TYPoint *pos = (TYPoint *)graphic.geometry;
        
        if (![groupedFacilityLabelDict.allKeys containsObject:@(categoryID)]) {
            NSMutableArray *array = [NSMutableArray array];
            [groupedFacilityLabelDict setObject:array forKey:@(categoryID)];
        }
        
        TYFacilityLabel *fLabel = [[TYFacilityLabel alloc] initWithCategoryID:categoryID Position:pos];
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
            for (TYFacilityLabel *fl in array) {
                fl.currentSymbol = fl.highlightedFacilitySymbol;
            }
        } else {
            for (TYFacilityLabel *fl in array) {
                fl.currentSymbol = fl.normalFacilitySymbol;
            }
        }
    }
    
    [self updateLabelState];
}

- (void)showAllFacilities
{
    for (NSArray *array in groupedFacilityLabelDict.allValues) {
        for (TYFacilityLabel *fl in array) {
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
            for (TYFacilityLabel *fl in array) {
                fl.currentSymbol = fl.highlightedFacilitySymbol;
            }
        } else {
            for (TYFacilityLabel *fl in array) {
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
    TYFacilityLabel *fl = [facilityLabelDict objectForKey:pid];
    AGSGraphic *graphic = fl.facilityGraphic;

    if (graphic) {
        result = [TYPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_FACILITY];
    }
    return result;
}

- (void)highlightPoi:(NSString *)poiID
{
    TYFacilityLabel *fl = [facilityLabelDict objectForKey:poiID];
    fl.currentSymbol = fl.highlightedFacilitySymbol;
    
    [self updateLabelState];
}

@end
