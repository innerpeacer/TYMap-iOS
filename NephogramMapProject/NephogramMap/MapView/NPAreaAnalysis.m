//
//  NPAreaAnalysis.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/24.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPAreaAnalysis.h"
#import <ArcGIS/ArcGIS.h>
#import "NPPoi.h"
#import "NPMapType.h"
#import "NPMapEnviroment.h"

@interface NPAreaAnalysis()
{
    NSMutableArray *featureArray;
}
@end

#define DEFAULT_BUFFER 1.0

@implementation NPAreaAnalysis

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _buffer = DEFAULT_BUFFER;
        
        NSError *error = nil;
        NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
        NSDictionary *dict = [parser objectWithString:jsonString];
        
        AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
        NSArray *allGraphics = set.features;

        featureArray = [[NSMutableArray alloc] init];
        for (AGSGraphic *graphic in allGraphics) {
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ROOM];
            [featureArray addObject:poi];
        }
        _areaCount = (int) featureArray.count;
    }
    return self;
}

- (NSArray *)extractAOIWithX:(double)x Y:(double)y
{
    NSMutableArray *resultArray = [NSMutableArray array];
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint *point = [AGSPoint pointWithX:x y:y spatialReference:[NPMapEnvironment defaultSpatialReference]];
    
    for (NPPoi *poi in featureArray) {
        AGSGeometry *bufferedGeometry = [engine bufferGeometry:poi.geometry byDistance:_buffer];
        if ([engine geometry:bufferedGeometry containsGeometry:point]) {
            [resultArray addObject:poi];
        }
    }
    return [NSArray arrayWithArray:resultArray];
}


@end
