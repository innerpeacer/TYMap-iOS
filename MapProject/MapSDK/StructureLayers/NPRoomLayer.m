//
//  TYRoomLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRoomLayer.h"
#import "NPMapType.h"
#import "TYMapFileManager.h"
#import "NPMapEnviroment.h"

@interface NPRoomLayer()
{
    AGSRenderer *roomRender;
    
    TYRenderingScheme *renderingScheme;
    
    NSMutableDictionary *roomDict;
}

@end

@implementation NPRoomLayer

+ (NPRoomLayer *)roomLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[NPRoomLayer alloc] initRoomLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initRoomLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        renderingScheme = aRenderingScheme;
        roomRender = [self createRoomRender];
        roomDict = [[NSMutableDictionary alloc] init];
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

- (void)loadContentsWithInfo:(TYMapInfo *)info
{
//    NSLog(@"addRoomContents");
    [self removeAllGraphics];
    [roomDict removeAllObjects];
    
    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getRoomLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    NSArray *allGraphics = set.features;
        
    for (AGSGraphic *g in allGraphics) {
        NSString *poiID = [g attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID];
        [roomDict setObject:g forKey:poiID];
    }
    
    [self addGraphics:allGraphics];
}

- (NPPoi *)getPoiWithPoiID:(NSString *)pid
{
    NPPoi *result = nil;
    AGSGraphic *graphic = [roomDict objectForKey:pid];
    if (graphic) {
        result = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ROOM];
    }
    return result;
}

- (void)highlightPoi:(NSString *)poiID
{
    AGSGraphic *graphic = [roomDict objectForKey:poiID];
    [self setSelected:YES forGraphic:graphic];
}

- (NPPoi *)extractPoiOnCurrentFloorWithX:(double)x Y:(double)y
{
    NPPoi *poi = nil;
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint *point = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
    for (NSString *poiID in roomDict.allKeys) {
        AGSGraphic *graphic = [roomDict objectForKey:poiID];
        if ([engine geometry:graphic.geometry containsGeometry:point]) {
            poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ROOM];
            break;
        }
    }
    return poi;
}

- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name
{
    NSArray *graphicArray = self.graphics;
    
    NPMapLanguage language = [TYMapEnvironment getMapLanguage];
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

- (AGSFeatureSet *)getFeatureSet
{
    NSArray *graphicArray = self.graphics;
    AGSFeatureSet *set = [AGSFeatureSet featureSetWithFeatures:graphicArray];
    return set;
}

@end

