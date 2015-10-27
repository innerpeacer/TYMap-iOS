//
//  TYMapInfoDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/10/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYMapInfoDBAdapter.h"
#import "TYMapInfoDBConstants.h"

#import <sqlite3.h>

@interface TYMapInfoDBAdapter()
{
    sqlite3 *_database;
    NSString *_dbPath;
}

@end

@implementation TYMapInfoDBAdapter

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _dbPath = path;
    }
    return self;
}

- (NSArray *)getAllMapInfos
{
    NSMutableArray *mapInfoArray = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSMutableString stringWithFormat:@"SELECT distinct %@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@  FROM %@ ", FIELD_MAPINFO_CITY_ID, FIELD_MAPINFO_BUILDING_ID, FIELD_MAPINFO_MAP_ID, FIELD_MAPINFO_FLOOR_NAME, FIELD_MAPINFO_FLOOR_NUMBER, FIELD_MAPINFO_SIZE_X, FIELD_MAPINFO_SIZE_Y, FIELD_MAPINFO_XMIN, FIELD_MAPINFO_YMIN, FIELD_MAPINFO_XMAX, FIELD_MAPINFO_YMAX, TABLE_MAPINFO];
    const char *selectSql = [sql UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *buildingID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *mapID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            NSString *floorName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            int floorNumber = sqlite3_column_int(statement, 4);
            
            double sizeX = sqlite3_column_double(statement, 5);
            double sizeY = sqlite3_column_double(statement, 6);
            double xMin = sqlite3_column_double(statement, 7);
            double yMin = sqlite3_column_double(statement, 8);
            double xMax = sqlite3_column_double(statement, 9);
            double yMax = sqlite3_column_double(statement, 10);
            
            TYMapInfo *info = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xMin, yMin, xMax, yMax) Size:TYMapSizeMake(sizeX, sizeY) Floor:floorName FloorNumber:floorNumber];
            [mapInfoArray addObject:info];
        }
    }
    sqlite3_finalize(statement);
    return mapInfoArray;
}

- (TYMapInfo *)getMapInfoWithFloor:(int)floor
{
    TYMapInfo *mapInfo = nil;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT distinct %@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@  FROM %@ ", FIELD_MAPINFO_CITY_ID, FIELD_MAPINFO_BUILDING_ID, FIELD_MAPINFO_MAP_ID, FIELD_MAPINFO_FLOOR_NAME, FIELD_MAPINFO_FLOOR_NUMBER, FIELD_MAPINFO_SIZE_X, FIELD_MAPINFO_SIZE_Y, FIELD_MAPINFO_XMIN, FIELD_MAPINFO_YMIN, FIELD_MAPINFO_XMAX, FIELD_MAPINFO_YMAX, TABLE_MAPINFO];
    [sql appendFormat:@" where %@ = %d ", FIELD_MAPINFO_FLOOR_NUMBER, floor];
    
    const char *selectSql = [sql UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *buildingID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *mapID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            NSString *floorName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            int floorNumber = sqlite3_column_int(statement, 4);
            
            double sizeX = sqlite3_column_double(statement, 5);
            double sizeY = sqlite3_column_double(statement, 6);
            double xMin = sqlite3_column_double(statement, 7);
            double yMin = sqlite3_column_double(statement, 8);
            double xMax = sqlite3_column_double(statement, 9);
            double yMax = sqlite3_column_double(statement, 10);
            
            mapInfo = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xMin, yMin, xMax, yMax) Size:TYMapSizeMake(sizeX, sizeY) Floor:floorName FloorNumber:floorNumber];
        }
    }
    sqlite3_finalize(statement);
    return mapInfo;
}

- (TYMapInfo *)getMapInfoWithMapID:(NSString *)mapID
{
    TYMapInfo *mapInfo = nil;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT distinct %@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@  FROM %@ ", FIELD_MAPINFO_CITY_ID, FIELD_MAPINFO_BUILDING_ID, FIELD_MAPINFO_MAP_ID, FIELD_MAPINFO_FLOOR_NAME, FIELD_MAPINFO_FLOOR_NUMBER, FIELD_MAPINFO_SIZE_X, FIELD_MAPINFO_SIZE_Y, FIELD_MAPINFO_XMIN, FIELD_MAPINFO_YMIN, FIELD_MAPINFO_XMAX, FIELD_MAPINFO_YMAX, TABLE_MAPINFO];
    [sql appendFormat:@" where %@ = '%@' ", FIELD_MAPINFO_MAP_ID, mapID];
    
    const char *selectSql = [sql UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *buildingID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *mapID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            NSString *floorName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            int floorNumber = sqlite3_column_int(statement, 4);
            
            double sizeX = sqlite3_column_double(statement, 5);
            double sizeY = sqlite3_column_double(statement, 6);
            double xMin = sqlite3_column_double(statement, 7);
            double yMin = sqlite3_column_double(statement, 8);
            double xMax = sqlite3_column_double(statement, 9);
            double yMax = sqlite3_column_double(statement, 10);
            
            mapInfo = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xMin, yMin, xMax, yMax) Size:TYMapSizeMake(sizeX, sizeY) Floor:floorName FloorNumber:floorNumber];
        }
    }
    sqlite3_finalize(statement);
    return mapInfo;
}

- (TYMapInfo *)getMapInfoWithName:(NSString *)floorName
{
    TYMapInfo *mapInfo = nil;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT distinct %@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@  FROM %@ ", FIELD_MAPINFO_CITY_ID, FIELD_MAPINFO_BUILDING_ID, FIELD_MAPINFO_MAP_ID, FIELD_MAPINFO_FLOOR_NAME, FIELD_MAPINFO_FLOOR_NUMBER, FIELD_MAPINFO_SIZE_X, FIELD_MAPINFO_SIZE_Y, FIELD_MAPINFO_XMIN, FIELD_MAPINFO_YMIN, FIELD_MAPINFO_XMAX, FIELD_MAPINFO_YMAX, TABLE_MAPINFO];
    [sql appendFormat:@" where %@ = '%@' ", FIELD_MAPINFO_FLOOR_NAME, floorName];
    
    const char *selectSql = [sql UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *buildingID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *mapID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            NSString *floorName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            int floorNumber = sqlite3_column_int(statement, 4);
            
            double sizeX = sqlite3_column_double(statement, 5);
            double sizeY = sqlite3_column_double(statement, 6);
            double xMin = sqlite3_column_double(statement, 7);
            double yMin = sqlite3_column_double(statement, 8);
            double xMax = sqlite3_column_double(statement, 9);
            double yMax = sqlite3_column_double(statement, 10);
            
            mapInfo = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xMin, yMin, xMax, yMax) Size:TYMapSizeMake(sizeX, sizeY) Floor:floorName FloorNumber:floorNumber];
        }
    }
    sqlite3_finalize(statement);
    return mapInfo;
}

- (BOOL)open
{
    if (sqlite3_open([_dbPath UTF8String], &_database) == SQLITE_OK) {
        //        NSLog(@"db open success!");
        return YES;
    } else {
        //        NSLog(@"db open failed!");
        return NO;
    }
}

- (BOOL)close
{
    return (sqlite3_close(_database) == SQLITE_OK);
}

@end
