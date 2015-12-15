//
//  TYMapInfo.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYMapInfo.h"
#import "TYMapFileManager.h"
#import <TYMapData/TYMapData.h>

#import "TYMapInfoDBAdapter.h"
#import "TYMapDBConstants.h"


MapExtent TYMapExtentMake(double xmin, double ymin, double xmax, double ymax)
{
    MapExtent extent  = {xmin, ymin, xmax, ymax};
    return extent;
}

MapSize TYMapSizeMake(double x, double y)
{
    MapSize size = { x, y };
    return size;
}

@implementation TYMapInfo

- (id)initWithCityID:(NSString *)cityID BuildingID:(NSString *)buidlingID MapID:(NSString *)mapID Extent:(MapExtent)e Size:(MapSize)s Floor:(NSString *)fs FloorNumber:(int)fi
{
    self = [super init];
    if (self) {
        _cityID = cityID;
        _buildingID = buidlingID;
        _mapID = mapID;
        _mapExtent = e;
        _mapSize = s;
        _floorName = fs;
        _floorNumber = fi;
        _scalex = _mapSize.x / (_mapExtent.xmax - _mapExtent.xmin);
        _scaley = _mapSize.y / (_mapExtent.ymax - _mapExtent.ymin);
    }
    return self;
}

+ (TYMapInfo *)parseMapInfo:(NSString *)floor ForBuilding:(TYBuilding *)building
{
    TYMapInfo *info = nil;
    NSString *dbPath = [TYMapFileManager getMapDataDBPath:building];
    TYMapInfoDBAdapter *db = [[TYMapInfoDBAdapter alloc] initWithPath:dbPath];
    [db open];
    info = [db getMapInfoWithName:floor];
    [db close];
    return info;
}

+ (NSArray *)parseAllMapInfo:(TYBuilding *)building
{
    NSArray *mapInfoArray = nil;
    NSString *dbPath = [TYMapFileManager getMapDataDBPath:building];
    TYMapInfoDBAdapter *db = [[TYMapInfoDBAdapter alloc] initWithPath:dbPath];
    [db open];
    mapInfoArray = [db getAllMapInfos];
    [db close];
    return mapInfoArray;
}

+ (NSArray *)parseAllMapInfoFromFile:(NSString *)path
{
    NSArray *mapInfoArray = nil;
    TYMapInfoDBAdapter *db = [[TYMapInfoDBAdapter alloc] initWithPath:path];
    [db open];
    mapInfoArray = [db getAllMapInfos];
    [db close];
    return mapInfoArray;
}

+ (TYMapInfo *)searchMapInfoFromArray:(NSArray *)array Floor:(int)floor
{
    for (TYMapInfo *info in array) {
        if (floor == info.floorNumber) {
            return info;
        }
    }
    return nil;
}

+ (TYMapInfo *)parseMapInfoObject:(NSDictionary *)mapInfoObject
{
    return [[TYMapInfo alloc] initWithCityID:mapInfoObject[FIELD_MAPINFO_1_CITY_ID] BuildingID:mapInfoObject[FIELD_MAPINFO_2_BUILDING_ID] MapID:mapInfoObject[FIELD_MAPINFO_3_MAP_ID] Extent:TYMapExtentMake([mapInfoObject[FIELD_MAPINFO_8_XMIN] doubleValue], [mapInfoObject[FIELD_MAPINFO_9_YMIN] doubleValue], [mapInfoObject[FIELD_MAPINFO_10_XMAX] doubleValue], [mapInfoObject[FIELD_MAPINFO_11_YMAX] doubleValue]) Size:TYMapSizeMake([mapInfoObject[FIELD_MAPINFO_6_SIZE_X] doubleValue], [mapInfoObject[FIELD_MAPINFO_7_SIZE_Y] doubleValue]) Floor:mapInfoObject[FIELD_MAPINFO_4_FLOOR_NAME] FloorNumber:[mapInfoObject[FIELD_MAPINFO_5_FLOOR_NUMBER] intValue]];
}

+ (NSDictionary *)buildingMapInfoObject:(TYMapInfo *)mapInfo
{
    NSMutableDictionary *mapInfoObject = [NSMutableDictionary dictionary];
    
    [mapInfoObject setObject:mapInfo.cityID forKey:FIELD_MAPINFO_1_CITY_ID];
    [mapInfoObject setObject:mapInfo.buildingID forKey:FIELD_MAPINFO_2_BUILDING_ID];
    [mapInfoObject setObject:mapInfo.mapID forKey:FIELD_MAPINFO_3_MAP_ID];
    
    [mapInfoObject setObject:mapInfo.floorName forKey:FIELD_MAPINFO_4_FLOOR_NAME];
    [mapInfoObject setObject:@(mapInfo.floorNumber) forKey:FIELD_MAPINFO_5_FLOOR_NUMBER];
    
    [mapInfoObject setObject:@(mapInfo.mapSize.x) forKey:FIELD_MAPINFO_6_SIZE_X];
    [mapInfoObject setObject:@(mapInfo.mapSize.y) forKey:FIELD_MAPINFO_7_SIZE_Y];
    
    [mapInfoObject setObject:@(mapInfo.mapExtent.xmin) forKey:FIELD_MAPINFO_8_XMIN];
    [mapInfoObject setObject:@(mapInfo.mapExtent.ymin) forKey:FIELD_MAPINFO_9_YMIN];
    [mapInfoObject setObject:@(mapInfo.mapExtent.xmax) forKey:FIELD_MAPINFO_10_XMAX];
    [mapInfoObject setObject:@(mapInfo.mapExtent.ymax) forKey:FIELD_MAPINFO_11_YMAX];
    
    return mapInfoObject;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MapID: %@, Floor: %@, Size: (%.2f, %.2f) Extent: (%.4f, %.4f, %.4f, %.4f)", _mapID, _floorName, _mapSize.x, _mapSize.y, _mapExtent.xmin, _mapExtent.ymin, _mapExtent.xmax, _mapExtent.ymax];
}

@end