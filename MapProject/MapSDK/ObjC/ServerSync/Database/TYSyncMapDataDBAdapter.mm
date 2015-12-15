//
//  TYSyncMapDataDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYSyncMapDataDBAdapter.h"
#import "TYMapDBConstants.h"
#include <sqlite3.h>

@interface TYSyncMapDataDBAdapter()
{
    sqlite3 *_database;
    NSString *_dbPath;
}

@end

@implementation TYSyncMapDataDBAdapter

- (id)initWithPath:(NSString *)path;
{
    self = [super init];
    if (self) {
        _dbPath = path;
        
    }
    return self;
}

- (BOOL)eraseMapDataTable
{
    NSString *errorString = @"Error: failed to erase MapData Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAP_DATA];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)eraseMapInfoTable
{
    NSString *errorString = @"Error: failed to erase MapInfo Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAPINFO];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)insertMapDataRecord:(TYSyncMapDataRecord *)record
{
    NSString *errorString = @"Error: failed to insert mapdata into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", TABLE_MAP_DATA, FIELD_MAP_DATA_1_OBJECT_ID, FIELD_MAP_DATA_2_GEOMETRY, FIELD_MAP_DATA_3_GEO_ID, FIELD_MAP_DATA_4_POI_ID, FIELD_MAP_DATA_5_FLOOR_ID, FIELD_MAP_DATA_6_BUILDING_ID, FIELD_MAP_DATA_7_CATEGORY_ID, FIELD_MAP_DATA_8_NAME, FIELD_MAP_DATA_9_SYMBOL_ID, FIELD_MAP_DATA_10_FLOOR_NUMBER, FIELD_MAP_DATA_11_FLOOR_NAME, FIELD_MAP_DATA_12_SHAPE_LENGTH, FIELD_MAP_DATA_13_SHAPE_AREA, FIELD_MAP_DATA_14_LABEL_X, FIELD_MAP_DATA_15_LABEL_Y, FIELD_MAP_DATA_16_LAYER];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [record.objectID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_blob(statement, 2, (const void *)[record.geometryData bytes], (int)[record.geometryData length], SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [record.geoID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 4, [record.poiID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 5, [record.floorID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 6, [record.buildingID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 7, [record.categoryID UTF8String], -1, SQLITE_STATIC);
    if (record.name == nil) {
        sqlite3_bind_null(statement, 8);
    } else {
        sqlite3_bind_text(statement, 8, [record.name UTF8String], -1, SQLITE_STATIC);
    }
    sqlite3_bind_int(statement, 9, record.symbolID);
    sqlite3_bind_int(statement, 10, record.floorNumber);
    sqlite3_bind_text(statement, 11, [record.floorName UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 12, record.shapeLength);
    sqlite3_bind_double(statement, 13, record.shapeArea);
    sqlite3_bind_double(statement, 14, record.labelX);
    sqlite3_bind_double(statement, 15, record.labelY);
    sqlite3_bind_int(statement, 16, record.layer);
      
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (int)insertMapDataRecords:(NSArray *)records
{
    int count = 0;
    for (TYSyncMapDataRecord *record in records) {
        BOOL success = [self insertMapDataRecord:record];
        if (success) {
            ++count;
        }
    }
    return count;
}

- (BOOL)insertMapInfo:(TYMapInfo *)mapInfo
{
    NSString *errorString = @"Error: failed to insert mapinfo into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", TABLE_MAPINFO, FIELD_MAPINFO_1_CITY_ID, FIELD_MAPINFO_2_BUILDING_ID, FIELD_MAPINFO_3_MAP_ID, FIELD_MAPINFO_4_FLOOR_NAME, FIELD_MAPINFO_5_FLOOR_NUMBER, FIELD_MAPINFO_6_SIZE_X, FIELD_MAPINFO_7_SIZE_Y, FIELD_MAPINFO_8_XMIN, FIELD_MAPINFO_9_YMIN, FIELD_MAPINFO_10_XMAX, FIELD_MAPINFO_11_YMAX];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [mapInfo.cityID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [mapInfo.buildingID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [mapInfo.mapID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 4, [mapInfo.floorName UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_int(statement, 5, mapInfo.floorNumber);
    sqlite3_bind_double(statement, 6, mapInfo.mapSize.x);
    sqlite3_bind_double(statement, 7, mapInfo.mapSize.y);
    sqlite3_bind_double(statement, 8, mapInfo.mapExtent.xmin);
    sqlite3_bind_double(statement, 9, mapInfo.mapExtent.ymin);
    sqlite3_bind_double(statement, 10, mapInfo.mapExtent.xmax);
    sqlite3_bind_double(statement, 11, mapInfo.mapExtent.ymax);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (int)insertMapInfos:(NSArray *)mapInfos
{
    int count = 0;
    for (TYMapInfo *mapInfo in mapInfos) {
        BOOL success = [self insertMapInfo:mapInfo];
        if (success) {
            ++count;
        }
    }
    return count;
}

- (BOOL)updateMapDataRecord:(TYSyncMapDataRecord *)record
{
    NSString *errorString = @"Error: failed to update mapdata";
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=? where %@=?", TABLE_MAP_DATA, FIELD_MAP_DATA_1_OBJECT_ID, FIELD_MAP_DATA_2_GEOMETRY, FIELD_MAP_DATA_3_GEO_ID, FIELD_MAP_DATA_4_POI_ID, FIELD_MAP_DATA_5_FLOOR_ID, FIELD_MAP_DATA_6_BUILDING_ID, FIELD_MAP_DATA_7_CATEGORY_ID, FIELD_MAP_DATA_8_NAME, FIELD_MAP_DATA_9_SYMBOL_ID, FIELD_MAP_DATA_10_FLOOR_NUMBER, FIELD_MAP_DATA_11_FLOOR_NAME, FIELD_MAP_DATA_12_SHAPE_LENGTH, FIELD_MAP_DATA_13_SHAPE_AREA, FIELD_MAP_DATA_14_LABEL_X, FIELD_MAP_DATA_15_LABEL_Y, FIELD_MAP_DATA_16_LAYER, FIELD_MAP_DATA_3_GEO_ID];
    //    NSLog(@"%@", sql);
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [record.objectID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_blob(statement, 2, (const void *)[record.geometryData bytes], (int)[record.geometryData length], SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [record.geoID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 4, [record.poiID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 5, [record.floorID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 6, [record.buildingID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 7, [record.categoryID UTF8String], -1, SQLITE_STATIC);
    if (record.name == nil) {
        sqlite3_bind_null(statement, 8);
    } else {
        sqlite3_bind_text(statement, 8, [record.name UTF8String], -1, SQLITE_STATIC);
    }
    sqlite3_bind_int(statement, 9, record.symbolID);
    sqlite3_bind_int(statement, 10, record.floorNumber);
    sqlite3_bind_text(statement, 11, [record.floorName UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 12, record.shapeLength);
    sqlite3_bind_double(statement, 13, record.shapeArea);
    sqlite3_bind_double(statement, 14, record.labelX);
    sqlite3_bind_double(statement, 15, record.labelY);
    sqlite3_bind_int(statement, 16, record.layer);
    sqlite3_bind_text(statement, 17, [record.geoID UTF8String], -1, SQLITE_STATIC);

    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (void)updateMapDataRecords:(NSArray *)records
{
    for (TYSyncMapDataRecord *record in records) {
        [self updateMapDataRecord:record];
    }
}

- (BOOL)updateMapInfo:(TYMapInfo *)mapInfo
{
    NSString *errorString = @"Error: failed to update mapinfo";
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=? where %@=?", TABLE_MAPINFO, FIELD_MAPINFO_1_CITY_ID, FIELD_MAPINFO_2_BUILDING_ID, FIELD_MAPINFO_3_MAP_ID, FIELD_MAPINFO_4_FLOOR_NAME, FIELD_MAPINFO_5_FLOOR_NUMBER, FIELD_MAPINFO_6_SIZE_X, FIELD_MAPINFO_7_SIZE_Y, FIELD_MAPINFO_8_XMIN, FIELD_MAPINFO_9_YMIN, FIELD_MAPINFO_10_XMAX, FIELD_MAPINFO_11_YMAX, FIELD_MAPINFO_3_MAP_ID];
    //    NSLog(@"%@", sql);
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [mapInfo.cityID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [mapInfo.buildingID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [mapInfo.mapID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 4, [mapInfo.floorName UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_int(statement, 5, mapInfo.floorNumber);
    sqlite3_bind_double(statement, 6, mapInfo.mapSize.x);
    sqlite3_bind_double(statement, 7, mapInfo.mapSize.y);
    sqlite3_bind_double(statement, 8, mapInfo.mapExtent.xmin);
    sqlite3_bind_double(statement, 9, mapInfo.mapExtent.ymin);
    sqlite3_bind_double(statement, 10, mapInfo.mapExtent.xmax);
    sqlite3_bind_double(statement, 11, mapInfo.mapExtent.ymax);
    sqlite3_bind_text(statement, 12, [mapInfo.mapID UTF8String], -1, SQLITE_STATIC);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (void)updateMapInfos:(NSArray *)mapInfos
{
    for (TYMapInfo *mapInfo in mapInfos) {
        [self updateMapInfo:mapInfo];
    }
}

- (BOOL)deleteMapDataRecord:(NSString *)geoID
{
    NSString *errorString = @"Error: failed to delete MapData";
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", TABLE_MAP_DATA, FIELD_MAP_DATA_3_GEO_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [geoID UTF8String], -1, SQLITE_STATIC);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)deleteMapInfo:(NSString *)mapID
{
    NSString *errorString = @"Error: failed to delete MapInfo";
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", TABLE_MAPINFO, FIELD_MAPINFO_3_MAP_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [mapID UTF8String], -1, SQLITE_STATIC);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (NSArray *)getAllMapInfos
{
    NSMutableArray *mapInfoArray = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSMutableString stringWithFormat:@"SELECT distinct %@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@ FROM %@", FIELD_MAPINFO_1_CITY_ID, FIELD_MAPINFO_2_BUILDING_ID, FIELD_MAPINFO_3_MAP_ID, FIELD_MAPINFO_4_FLOOR_NAME, FIELD_MAPINFO_5_FLOOR_NUMBER, FIELD_MAPINFO_6_SIZE_X, FIELD_MAPINFO_7_SIZE_Y, FIELD_MAPINFO_8_XMIN, FIELD_MAPINFO_9_YMIN, FIELD_MAPINFO_10_XMAX, FIELD_MAPINFO_11_YMAX, TABLE_MAPINFO];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
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
            
            MapSize size = { sizeX, sizeY };
            MapExtent extent = { xMin, yMin, xMax, yMax };
            TYMapInfo *info = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:extent Size:size Floor:floorName FloorNumber:floorNumber];

            [mapInfoArray addObject:info];
        }
    }
    sqlite3_finalize(statement);
    return mapInfoArray;
}


- (NSArray *)getAllRecords
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"select OBJECT_ID, GEOMETRY, GEO_ID, POI_ID, FLOOR_ID, BUILDING_ID, CATEGORY_ID, NAME, SYMBOL_ID, FLOOR_NUMBER, FLOOR_NAME, SHAPE_LENGTH, SHAPE_AREA, LABEL_X, LABEL_Y, LAYER from MAPDATA"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            TYSyncMapDataRecord *record = [[TYSyncMapDataRecord alloc] init];
            
            NSString *objectID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSData *geoData = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 1) length:sqlite3_column_bytes(statement, 1)];
            NSString *geoID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            NSString *poiID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            NSString *floorID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            NSString *buildingID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            NSString *categoryID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            
            NSString *name = nil;
            if (sqlite3_column_type(statement, 7) != SQLITE_NULL) {
                name = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            }
            int symbolID = sqlite3_column_int(statement, 8);
            int floorNumber = sqlite3_column_int(statement, 9);
            NSString *floorName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 10) encoding:NSUTF8StringEncoding];
            
            double shapeLength = sqlite3_column_double(statement, 11);
            double shapeArea = sqlite3_column_double(statement, 12);
            double labelX = sqlite3_column_double(statement, 13);
            double labelY = sqlite3_column_double(statement, 14);
            int layer = sqlite3_column_int(statement, 15);
            
            record.objectID = objectID;
            record.geometryData = geoData;
            record.geoID = geoID;
            record.poiID =poiID;
            record.floorID = floorID;
            record.buildingID = buildingID;
            record.categoryID = categoryID;
            record.name = name;
            
            record.symbolID = symbolID;
            record.floorNumber = floorNumber;
            record.floorName = floorName;
            record.shapeLength = shapeLength;
            record.shapeArea = shapeArea;
            record.labelX = labelX;
            record.labelY = labelY;
            record.layer = layer;
            
            [array addObject:record];
        }
    }
    sqlite3_finalize(statement);
    
    return array;
}


- (void)createTablesIfNotExists
{
    {
        NSString *mapInfoSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", TABLE_MAPINFO,
                                [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_MAPINFO_0_PRIMARY_KEY],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAPINFO_1_CITY_ID],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAPINFO_2_BUILDING_ID],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAPINFO_3_MAP_ID],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAPINFO_4_FLOOR_NAME],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_MAPINFO_5_FLOOR_NUMBER],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAPINFO_6_SIZE_X],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAPINFO_7_SIZE_Y],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAPINFO_8_XMIN],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAPINFO_9_YMIN],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAPINFO_10_XMAX],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAPINFO_11_YMAX]];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [mapInfoSql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create mapinfo table failed!");
            return;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    
    {
        NSString *mapDataSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) ", TABLE_MAP_DATA,
                                [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_MAP_DATA_0_PRIMARY_KEY],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_DATA_1_OBJECT_ID],
                                [NSString stringWithFormat:@"%@ blob not null", FIELD_MAP_DATA_2_GEOMETRY],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_DATA_3_GEO_ID],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_DATA_4_POI_ID],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_DATA_5_FLOOR_ID],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_DATA_6_BUILDING_ID],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_DATA_7_CATEGORY_ID],
                                [NSString stringWithFormat:@"%@ text", FIELD_MAP_DATA_8_NAME],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_DATA_9_SYMBOL_ID],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_DATA_10_FLOOR_NUMBER],
                                [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_DATA_11_FLOOR_NAME],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAP_DATA_12_SHAPE_LENGTH],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAP_DATA_13_SHAPE_AREA],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAP_DATA_14_LABEL_X],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_MAP_DATA_15_LABEL_Y],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_DATA_16_LAYER]];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [mapDataSql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create city table failed!");
            return;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

- (BOOL)open
{
    if (sqlite3_open([_dbPath UTF8String], &_database) == SQLITE_OK) {
        //        NSLog(@"db open success!");
        [self createTablesIfNotExists];
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
