//
//  IPSyncMapDataRecord.m
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPSyncMapDataRecord.h"
#import "IPBase64Encoding.h"
#import "NSData+GZIP.h"
#import "IPMapDBConstants.h"

@implementation IPSyncMapDataRecord

+ (IPSyncMapDataRecord *)parseMapDataRecord:(NSDictionary *)recordObject
{
    IPSyncMapDataRecord *record = [[IPSyncMapDataRecord alloc] init];
    
    record.objectID = recordObject[FIELD_MAP_DATA_1_OBJECT_ID];
//    record.geometryData = [TYBase64Encoding decodingString:recordObject[FIELD_MAP_DATA_2_GEOMETRY]];
    record.geometryData = [[IPBase64Encoding decodingString:recordObject[FIELD_MAP_DATA_2_GEOMETRY]] gunzippedData];
    record.geoID = recordObject[FIELD_MAP_DATA_3_GEO_ID];
    record.poiID = recordObject[FIELD_MAP_DATA_4_POI_ID];
    record.floorID = recordObject[FIELD_MAP_DATA_5_FLOOR_ID];
    record.buildingID = recordObject[FIELD_MAP_DATA_6_BUILDING_ID];
    record.categoryID = recordObject[FIELD_MAP_DATA_7_CATEGORY_ID];
    record.name = recordObject[FIELD_MAP_DATA_8_NAME];
    record.symbolID = [recordObject[FIELD_MAP_DATA_9_SYMBOL_ID] intValue];
    record.floorNumber = [recordObject[FIELD_MAP_DATA_10_FLOOR_NUMBER] intValue];
    record.floorName = recordObject[FIELD_MAP_DATA_11_FLOOR_NAME];
    record.shapeLength = [recordObject[FIELD_MAP_DATA_12_SHAPE_LENGTH] doubleValue];
    record.shapeArea = [recordObject[FIELD_MAP_DATA_13_SHAPE_AREA] doubleValue];
    record.labelX = [recordObject[FIELD_MAP_DATA_14_LABEL_X] doubleValue];
    record.labelY = [recordObject[FIELD_MAP_DATA_15_LABEL_Y] doubleValue];
    record.layer = [recordObject[FIELD_MAP_DATA_16_LAYER] intValue];
    record.levelMax = [recordObject[FIELD_MAP_DATA_17_LEVEL_MAX] intValue];
    record.levelMin = [recordObject[FIELD_MAP_DATA_18_LEVEL_MIN] intValue];
    
    return record;
}

+ (NSDictionary *)buildMapDataObject:(IPSyncMapDataRecord *)record
{
    NSMutableDictionary *dataObject = [NSMutableDictionary dictionary];
    
    [dataObject setObject:record.objectID forKey:FIELD_MAP_DATA_1_OBJECT_ID];
//    [dataObject setObject:[TYBase64Encoding encodeingData:record.geometryData] forKey:FIELD_MAP_DATA_2_GEOMETRY];
    [dataObject setObject:[IPBase64Encoding encodeingData:[record.geometryData gzippedData]] forKey:FIELD_MAP_DATA_2_GEOMETRY];

    [dataObject setObject:record.geoID forKey:FIELD_MAP_DATA_3_GEO_ID];
    [dataObject setObject:record.poiID forKey:FIELD_MAP_DATA_4_POI_ID];
    [dataObject setObject:record.floorID forKey:FIELD_MAP_DATA_5_FLOOR_ID];
    [dataObject setObject:record.buildingID forKey:FIELD_MAP_DATA_6_BUILDING_ID];
    [dataObject setObject:record.categoryID forKey:FIELD_MAP_DATA_7_CATEGORY_ID];
    if (record.name) {
        [dataObject setObject:record.name forKey:FIELD_MAP_DATA_8_NAME];
    }
//    else {
//        [dataObject setObject:[NSNull null] forKey:FIELD_MAP_DATA_8_NAME];
//    }

    [dataObject setObject:@(record.symbolID) forKey:FIELD_MAP_DATA_9_SYMBOL_ID];
    [dataObject setObject:@(record.floorNumber) forKey:FIELD_MAP_DATA_10_FLOOR_NUMBER];
    [dataObject setObject:record.floorName forKey:FIELD_MAP_DATA_11_FLOOR_NAME];

    [dataObject setObject:@(record.shapeLength) forKey:FIELD_MAP_DATA_12_SHAPE_LENGTH];
    [dataObject setObject:@(record.shapeArea) forKey:FIELD_MAP_DATA_13_SHAPE_AREA];
    [dataObject setObject:@(record.labelX) forKey:FIELD_MAP_DATA_14_LABEL_X];
    [dataObject setObject:@(record.labelY) forKey:FIELD_MAP_DATA_15_LABEL_Y];
    [dataObject setObject:@(record.layer) forKey:FIELD_MAP_DATA_16_LAYER];
    [dataObject setObject:@(record.levelMax) forKey:FIELD_MAP_DATA_17_LEVEL_MAX];
    [dataObject setObject:@(record.levelMin) forKey:FIELD_MAP_DATA_18_LEVEL_MIN];
    
    return dataObject;
}

@end
