//
//  NPFacilityLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPFacilityLayer.h"
#import "NPMapType.h"

@interface NPFacilityLayer()
{
    NSMutableDictionary *groupedFacilityDict;
    NSMutableDictionary *facilityDict;
    
    NPRenderingScheme *renderingScheme;
    
    AGSRenderer *facilityRender;
}

@end

@implementation NPFacilityLayer

+ (NPFacilityLayer *)facilityLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[NPFacilityLayer alloc] initFacilityLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initFacilityLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        renderingScheme = aRenderingScheme;
        facilityRender = [self createFacilityRenderer];
        self.renderer = facilityRender;
        groupedFacilityDict = [[NSMutableDictionary alloc] init];
        facilityDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (AGSRenderer *)createFacilityRenderer
{
    AGSUniqueValueRenderer *render = [[AGSUniqueValueRenderer alloc] init];
    NSMutableArray *facilityUVs = [[NSMutableArray alloc] init];
    
    NSDictionary *iconDict = renderingScheme.iconSymbolDictionary;
    
    NSEnumerator *enumerator = [iconDict keyEnumerator];
    
    id key;
    while ((key = [enumerator nextObject])) {
        NSString *icon = iconDict[key];
        AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:icon];
        pms.size = CGSizeMake(16, 16);
        AGSUniqueValue *uv = [AGSUniqueValue uniqueValueWithValue:[NSString stringWithFormat:@"%@", key] symbol:pms];
        [facilityUVs addObject:uv];
    }
    
    render.uniqueValues = facilityUVs;
    render.fields = @[@"COLOR"];
    
    return render;
}

- (void)loadContentsWithInfo:(NPMapInfo *)info;
{
//    NSLog(@"addFacilityContents");
    
    [self removeAllGraphics];
    [groupedFacilityDict removeAllObjects];
    [facilityDict removeAllObjects];
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_FACILITY",info.mapID] ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
    
    for (AGSGraphic *graphic in allGraphics) {
        int categoryID = [[graphic attributeForKey:@"COLOR"] intValue];
        
        if (![groupedFacilityDict.allKeys containsObject:@(categoryID)]) {
            NSMutableArray *array = [NSMutableArray array];
            [groupedFacilityDict setObject:array forKey:@(categoryID)];
        }
        
        NSMutableArray *array = groupedFacilityDict[@(categoryID)];
        [array addObject:graphic];
        
        NSString *poiID = [graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID];
        [facilityDict setObject:graphic forKey:poiID];
    }
    
    [self addGraphics:allGraphics];
}

- (void)showFacilityWithCategory:(int)categoryID
{
    [self removeAllGraphics];
    NSArray *array = groupedFacilityDict[@(categoryID)];
    if (array) {
        [self addGraphics:array];
    }
}

- (void)showAllFacilities
{
    [self removeAllGraphics];
    for (NSArray *array in groupedFacilityDict.allValues) {
        [self addGraphics:array];
    }
}

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs
{
    [self removeAllGraphics];
    for (NSNumber *categoryID in categoryIDs) {
        NSArray *array = groupedFacilityDict[categoryID];
        if (array) {
            [self addGraphics:array];
        }
    }
}

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor
{
    return [groupedFacilityDict allKeys];
}

- (NPPoi *)getPoiWithPoiID:(NSString *)pid
{
    NPPoi *result = nil;
    AGSGraphic *graphic = [facilityDict objectForKey:pid];
    if (graphic) {
        result = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_FACILITY];
    }
    return result;
}

@end
