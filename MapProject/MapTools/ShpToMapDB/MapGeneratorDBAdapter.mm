//
//  MapGeneratorDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "MapGeneratorDBAdapter.h"

#import "FMDatabase.h"

#import "TYMapDBConstants.h"
#import "TYMapInfo.h"
#import "OriginalShpRecord.h"
#import "TYMapEnviroment.h"

#import "TYMapFileManager.h"
#include "IPEncryption.hpp"
#import "SymbolRecord.h"

@interface MapGeneratorDBAdapter()
{
    TYBuilding *building;
    FMDatabase *db;
}

@end

@implementation MapGeneratorDBAdapter

- (id)initWithBuilding:(TYBuilding *)b
{
    self = [super init];
    if (self) {
        building = b;
        NSString *dbPath = [TYMapFileManager getMapDataDBPath:building];
        db = [FMDatabase databaseWithPath:dbPath];
        [self checkDatabase];
    }
    return self;
}


- (void)insertMapInfos:(NSArray *)mapInfoArray
{
    for (TYMapInfo *info in mapInfoArray) {
        [self insertMapInfo:info];
    }
}

- (void)insertMapData:(NSArray *)mapDataArray
{
    for (OriginalShpRecord *record in mapDataArray) {
        [self insertShpRecord:record];
    }
}


- (void)insertFillSymbols:(NSArray *)symbolArray
{
    for (FillSymbolRecord *record in symbolArray) {
        [self insertFillSymbolRecord:record];
    }
}

- (void)insertIconSymbols:(NSArray *)symbolArray
{
    for (IconSymbolRecord *record in symbolArray) {
        [self insertIconSymbolRecord:record];
    }
}

- (BOOL)insertMapInfo:(TYMapInfo *)info
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"insert into %@ ", TABLE_MAPINFO];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", FIELD_MAPINFO_1_CITY_ID, FIELD_MAPINFO_2_BUILDING_ID, FIELD_MAPINFO_3_MAP_ID, FIELD_MAPINFO_4_FLOOR_NAME, FIELD_MAPINFO_5_FLOOR_NUMBER, FIELD_MAPINFO_6_SIZE_X, FIELD_MAPINFO_7_SIZE_Y, FIELD_MAPINFO_8_XMIN, FIELD_MAPINFO_9_YMIN, FIELD_MAPINFO_10_XMAX, FIELD_MAPINFO_11_YMAX];
    NSString *values = @" (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
    
    [arguments addObject:info.cityID];
    [arguments addObject:info.buildingID];
    [arguments addObject:info.mapID];
    [arguments addObject:info.floorName];
    [arguments addObject:@(info.floorNumber)];
    
    [arguments addObject:@(info.mapSize.x)];
    [arguments addObject:@(info.mapSize.y)];
    [arguments addObject:@(info.mapExtent.xmin)];
    [arguments addObject:@(info.mapExtent.ymin)];
    [arguments addObject:@(info.mapExtent.xmax)];
    [arguments addObject:@(info.mapExtent.ymax)];
    
    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [db executeUpdate:sql withArgumentsInArray:arguments];
}

- (BOOL)insertShpRecord:(OriginalShpRecord *)record
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"insert into %@", TABLE_MAP_DATA];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", FIELD_MAP_DATA_1_OBJECT_ID, FIELD_MAP_DATA_2_GEOMETRY, FIELD_MAP_DATA_3_GEO_ID, FIELD_MAP_DATA_4_POI_ID, FIELD_MAP_DATA_5_FLOOR_ID, FIELD_MAP_DATA_6_BUILDING_ID, FIELD_MAP_DATA_7_CATEGORY_ID, FIELD_MAP_DATA_8_NAME, FIELD_MAP_DATA_9_SYMBOL_ID, FIELD_MAP_DATA_10_FLOOR_NUMBER, FIELD_MAP_DATA_11_FLOOR_NAME, FIELD_MAP_DATA_12_SHAPE_LENGTH, FIELD_MAP_DATA_13_SHAPE_AREA, FIELD_MAP_DATA_14_LABEL_X, FIELD_MAP_DATA_15_LABEL_Y, FIELD_MAP_DATA_16_LAYER, FIELD_MAP_DATA_17_LEVEL_MAX, FIELD_MAP_DATA_18_LEVEL_MIN];
    NSString *values = @" ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";

    
    [arguments addObject:record.objectID];
    
    // Encrypt Geometry Data
    {
        int geometryByteLength = (int)record.geometryData.length;
        char originalBytes[geometryByteLength + 1];
        [record.geometryData getBytes:originalBytes];
        char encryptedBytes[geometryByteLength + 1];
        encryptBytes(originalBytes, encryptedBytes, geometryByteLength);
        NSData *encryptedData = [NSData dataWithBytes:encryptedBytes length:geometryByteLength];
        [arguments addObject:encryptedData];
    }
//    [arguments addObject:record.geometryData];

    
    [arguments addObject:record.geoID];
    [arguments addObject:record.poiID];
    [arguments addObject:record.floorID];
    [arguments addObject:record.buildingID];
    [arguments addObject:record.categoryID];
    [arguments addObject:record.name == nil ? [NSNull null] : record.name];
    [arguments addObject:record.symbolID];
    [arguments addObject:record.floorNumber];
    [arguments addObject:record.floorName];
    [arguments addObject:record.shapeLength];
    [arguments addObject:record.shapeArea];
    [arguments addObject:record.labelX];
    [arguments addObject:record.labelY];
    [arguments addObject:record.layer];
    [arguments addObject:record.levelMax];
    [arguments addObject:record.levelMin];
    
    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [db executeUpdate:sql withArgumentsInArray:arguments];
}

- (BOOL)insertFillSymbolRecord:(FillSymbolRecord *)record
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"insert into %@ ", TABLE_MAP_SYMBOL_FILL_SYMBOL];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" (%@, %@, %@, %@)", FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID, FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR, FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR, FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH];
    NSString *values = @" (?, ?, ?, ?) ";
    
    [arguments addObject:@(record.symbolID)];
    [arguments addObject:record.fillColor];
    [arguments addObject:record.outlineColor];
    [arguments addObject:@(record.lineWidth)];
    
    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [db executeUpdate:sql withArgumentsInArray:arguments];
}

- (BOOL)insertIconSymbolRecord:(IconSymbolRecord *)record
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"insert into %@ ", TABLE_MAP_SYMBOL_ICON_SYMBOL];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" (%@, %@)", FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID, FIELD_MAP_SYMBOL_ICON_2_ICON];
    NSString *values = @" (?, ?) ";
    
    [arguments addObject:@(record.symbolID)];
    [arguments addObject:record.icon];
    
    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [db executeUpdate:sql withArgumentsInArray:arguments];
}


- (BOOL)createMapDataTable
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) ", TABLE_MAP_DATA,
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
                     [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_DATA_16_LAYER],
                     [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_DATA_17_LEVEL_MAX],
                     [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_DATA_18_LEVEL_MIN]];
    
    if ([db executeUpdate:sql]) {
        return YES;
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)createMapInfoTable
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", TABLE_MAPINFO,
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
    if ([db executeUpdate:sql]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)createFillSymbolTable
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@) ", TABLE_MAP_SYMBOL_FILL_SYMBOL,
                     [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_MAP_SYMBOL_FILL_0_PRIMARY_KEY],
                     [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID],
                     [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR],
                     [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR],
                     [NSString stringWithFormat:@"%@ real not null", FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH]
                     ];
    if ([db executeUpdate:sql]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)createIconSymbolTable
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@) ", TABLE_MAP_SYMBOL_ICON_SYMBOL,
                     [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_MAP_SYMBOL_ICON_0_PRIMARY_KEY],
                     [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID],
                     [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_SYMBOL_ICON_2_ICON]
                     ];
    if ([db executeUpdate:sql]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)eraseDatabase
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAPINFO];
    [db executeUpdate:sql];
    sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAP_DATA];
    [db executeUpdate:sql];
    sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAP_SYMBOL_FILL_SYMBOL];
    [db executeUpdate:sql];
    sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAP_SYMBOL_ICON_SYMBOL];
    [db executeUpdate:sql];
}


- (void)checkDatabase
{
    [db open];
    if (![self existTable:TABLE_MAPINFO]) {
        [self createMapInfoTable];
    }
    
    if (![self existTable:TABLE_MAP_DATA]) {
        [self createMapDataTable];
    }
    
    if (![self existTable:TABLE_MAP_SYMBOL_FILL_SYMBOL]) {
        [self createFillSymbolTable];
    }
    
    if (![self existTable:TABLE_MAP_SYMBOL_ICON_SYMBOL]) {
        [self createIconSymbolTable];
    }
}

- (BOOL)existTable:(NSString *)table
{
    if (!table) {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",table];
    
    FMResultSet *set = [db executeQuery:sql];
    if([set next])
    {
        NSInteger count = [set intForColumnIndex:0];
        if (count > 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (BOOL)open
{
    return [db open];
}

- (BOOL)close
{
    return [db close];
}

@end
