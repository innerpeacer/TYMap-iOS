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

- (NSString *)description
{
    return [NSString stringWithFormat:@"MapID: %@, Floor: %@, Size: (%.2f, %.2f) Extent: (%.4f, %.4f, %.4f, %.4f)", _mapID, _floorName, _mapSize.x, _mapSize.y, _mapExtent.xmin, _mapExtent.ymin, _mapExtent.xmax, _mapExtent.ymax];
}

@end