//
//  MapGeneratorDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "MapGeneratorDBAdapter.h"

#import "FMDatabase.h"

#import "MapDBConstants.h"
#import "TYMapInfo.h"
#import "OriginalShpRecord.h"
#import "TYMapEnviroment.h"

#import "TYMapFileManager.h"
#include "IPEncryption.hpp"

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
        NSString *dbPath = [TYMapFileManager getMapDBPath:building];
        db = [FMDatabase databaseWithPath:dbPath];
        [self checkDatabase];
    }
    return self;
}

- (BOOL)insertMapInfo:(TYMapInfo *)info
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"insert into %@ ", TABLE_MAPINFO];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", MAPINFO_FIELD_CITY_ID, MAPINFO_FIELD_BUILDING_ID, MAPINFO_FIELD_MAP_ID, MAPINFO_FIELD_FLOOR_NAME, MAPINFO_FIELD_FLOOR_NUMBER, MAPINFO_FIELD_SIZE_X, MAPINFO_FIELD_SIZE_Y, MAPINFO_FIELD_X_MIN, MAPINFO_FIELD_Y_MIN, MAPINFO_FIELD_X_MAX, MAPINFO_FIELD_Y_MAX];
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

- (BOOL)insertShpRecord:(OriginalShpRecord *)record
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"insert into %@", TABLE_MAP_DATA];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", MAP_CONTENT_FIELD_OBJECT_ID, MAP_CONTENT_FIELD_GEOMETRY, MAP_CONTENT_FIELD_GEO_ID, MAP_CONTENT_FIELD_POI_ID, MAP_CONTENT_FIELD_FLOOR_ID, MAP_CONTENT_FIELD_BUILDING_ID, MAP_CONTENT_FIELD_CATEGORY_ID, MAP_CONTENT_FIELD_NAME, MAP_CONTENT_FIELD_SYMBOL_ID, MAP_CONTENT_FIELD_FLOOR_NUMBER, MAP_CONTENT_FIELD_FLOOR_NAME, MAP_CONTENT_FIELD_SHAPE_LENGTH, MAP_CONTENT_FIELD_SHAPE_AREA, MAP_CONTENT_FIELD_LABEL_X, MAP_CONTENT_FIELD_LABEL_Y, MAP_CONTENT_FIELD_LAYER];
    NSString *values = @" ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
    
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
    
//    if (record.layer.intValue == 5) {
//        int geometryByteLength = (int)record.geometryData.length;
//        char gBytes[geometryByteLength + 1];
//        memset(gBytes, 0, sizeof(gBytes)/sizeof(char));
//        
//        [record.geometryData getBytes:gBytes];
//        
//        printf("Geometry Bytes: %d\n", geometryByteLength);
//        for (int i = 0; i < geometryByteLength; ++i) {
//            printf("%4d, ", gBytes[i]);
//        }
//        printf("\n");
//        
//        char encryptedBytes[geometryByteLength + 1];
//        encryptBytes(gBytes, encryptedBytes, geometryByteLength);
//        
//        printf("Encrypted Bytes: %d\n", geometryByteLength);
//        for (int i = 0; i < geometryByteLength; ++i) {
//            printf("%4d, ", encryptedBytes[i]);
//        }
//        printf("\n");
//        
//        char backBytes[geometryByteLength + 1];
//        decryptBytes(encryptedBytes, backBytes, geometryByteLength);
//        
//        printf("Decrypted Back Bytes: %d\n", geometryByteLength);
//        for (int i = 0; i < geometryByteLength; ++i) {
//            printf("%4d, ", backBytes[i]);
//        }
//        printf("\n\n");
//    }
    
    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [db executeUpdate:sql withArgumentsInArray:arguments];
}


- (BOOL)createMapDataTable
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table %@ ( ", TABLE_MAP_DATA];
    
    [sql appendFormat:@"%@ integer primary key autoincrement, ", MAP_CONTENT_FIELD_ID];
    [sql appendFormat:@"%@ integer not null, ", MAP_CONTENT_FIELD_OBJECT_ID];
    [sql appendFormat:@"%@ blob not null, ", MAP_CONTENT_FIELD_GEOMETRY];
    [sql appendFormat:@"%@ text not null, ", MAP_CONTENT_FIELD_GEO_ID];
    [sql appendFormat:@"%@ text not null, ", MAP_CONTENT_FIELD_POI_ID];
    [sql appendFormat:@"%@ text not null, ", MAP_CONTENT_FIELD_FLOOR_ID];
    [sql appendFormat:@"%@ text not null, ", MAP_CONTENT_FIELD_BUILDING_ID];
    [sql appendFormat:@"%@ text not null, ", MAP_CONTENT_FIELD_CATEGORY_ID];
    [sql appendFormat:@"%@ text, ", MAP_CONTENT_FIELD_NAME];
    [sql appendFormat:@"%@ integer not null, ", MAP_CONTENT_FIELD_SYMBOL_ID];
    [sql appendFormat:@"%@ integer not null, ", MAP_CONTENT_FIELD_FLOOR_NUMBER];
    [sql appendFormat:@"%@ text not null, ", MAP_CONTENT_FIELD_FLOOR_NAME];
    [sql appendFormat:@"%@ real not null, ", MAP_CONTENT_FIELD_SHAPE_LENGTH];
    [sql appendFormat:@"%@ real not null, ", MAP_CONTENT_FIELD_SHAPE_AREA];
    [sql appendFormat:@"%@ real not null, ", MAP_CONTENT_FIELD_LABEL_X];
    [sql appendFormat:@"%@ real not null, ", MAP_CONTENT_FIELD_LABEL_Y];
    [sql appendFormat:@"%@ integer not null ", MAP_CONTENT_FIELD_LAYER];

    [sql appendString:@" )"];
    
    if ([db executeUpdate:sql]) {
        return YES;
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)createMapInfoTable
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table %@ ( ", TABLE_MAPINFO];
    
    [sql appendFormat:@"%@ integer primary key autoincrement, ", MAPINFO_FIELD_ID];
    [sql appendFormat:@"%@ text not null, ", MAPINFO_FIELD_CITY_ID];
    [sql appendFormat:@"%@ text not null, ", MAPINFO_FIELD_BUILDING_ID];
    [sql appendFormat:@"%@ text not null, ", MAPINFO_FIELD_MAP_ID];
    [sql appendFormat:@"%@ text not null, ", MAPINFO_FIELD_FLOOR_NAME];
    [sql appendFormat:@"%@ integer not null, ", MAPINFO_FIELD_FLOOR_NUMBER];
    [sql appendFormat:@"%@ real not null, ", MAPINFO_FIELD_SIZE_X];
    [sql appendFormat:@"%@ real not null, ", MAPINFO_FIELD_SIZE_Y];
    [sql appendFormat:@"%@ real not null, ", MAPINFO_FIELD_X_MIN];
    [sql appendFormat:@"%@ real not null, ", MAPINFO_FIELD_Y_MIN];
    [sql appendFormat:@"%@ real not null, ", MAPINFO_FIELD_X_MAX];
    [sql appendFormat:@"%@ real not null ", MAPINFO_FIELD_Y_MAX];
    
    [sql appendString:@" )"];
    
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
