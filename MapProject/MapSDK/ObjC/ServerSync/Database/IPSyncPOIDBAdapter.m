//
//  IPSyncPOIDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/12/25.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPSyncPOIDBAdapter.h"
#import "IPMapDBConstants.h"
#include <sqlite3.h>
#import "TYPoi.h"

@interface IPSyncPOIDBAdapter()
{
    sqlite3 *_database;
    NSString *_dbPath;
}

@end

@implementation IPSyncPOIDBAdapter

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _dbPath = path;
    }
    return self;
}

- (BOOL)erasePOITable
{
    NSString *errorString = @"Error: failed to erase POI Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_POI];
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

- (BOOL)insertPOIRecord:(IPSyncMapDataRecord *)record
{
    NSString *errorString = @"Error: failed to insert poi into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", TABLE_POI, FIELD_POI_1_GEO_ID, FIELD_POI_2_POI_ID, FIELD_POI_3_BUILDING_ID, FIELD_POI_4_FLOOR_ID, FIELD_POI_5_NAME, FIELD_POI_6_CATEGORY_ID, FIELD_POI_7_LABEL_X, FIELD_POI_8_LABEL_Y, FIELD_POI_9_SYMBOL_ID, FIELD_POI_10_FLOOR_NUMBER, FIELD_POI_11_FLOOR_NAME, FIELD_POI_12_LAYER];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [record.geoID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [record.poiID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [record.buildingID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 4, [record.floorID UTF8String], -1, SQLITE_STATIC);
    if (record.name == nil) {
        sqlite3_bind_null(statement, 5);
    } else {
        sqlite3_bind_text(statement, 5, [record.name UTF8String], -1, SQLITE_STATIC);
    }
    sqlite3_bind_int(statement, 6, [record.categoryID intValue]);
    sqlite3_bind_double(statement, 7, record.labelX);
    sqlite3_bind_double(statement, 8, record.labelY);
    sqlite3_bind_int(statement, 9, record.symbolID);
    sqlite3_bind_int(statement, 10, record.floorNumber);
    sqlite3_bind_text(statement, 11, [record.floorName UTF8String], -1, SQLITE_STATIC);
    
    int layer;
    // Room Layer
    if (record.layer == 2) {
        layer = POI_ROOM;
    }
    // Asset Layer
    else if (record.layer == 3) {
        layer = POI_ASSET;
    }
    // Facility Layer
    else if (record.layer == 4) {
        layer = POI_FACILITY;
    }
    sqlite3_bind_int(statement, 12, layer);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (int)insertPOIRecords:(NSArray *)recordArray
{
    int count = 0;
    sqlite3_exec(_database,"begin;",0,0,0);
    
    NSString *errorString = @"Error: failed to insert poi into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", TABLE_POI, FIELD_POI_1_GEO_ID, FIELD_POI_2_POI_ID, FIELD_POI_3_BUILDING_ID, FIELD_POI_4_FLOOR_ID, FIELD_POI_5_NAME, FIELD_POI_6_CATEGORY_ID, FIELD_POI_7_LABEL_X, FIELD_POI_8_LABEL_Y, FIELD_POI_9_SYMBOL_ID, FIELD_POI_10_FLOOR_NUMBER, FIELD_POI_11_FLOOR_NAME, FIELD_POI_12_LAYER];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    for (IPSyncMapDataRecord *record in recordArray) {
        sqlite3_reset(statement);
        sqlite3_bind_text(statement, 1, [record.geoID UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 2, [record.poiID UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 3, [record.buildingID UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 4, [record.floorID UTF8String], -1, SQLITE_STATIC);
        if (record.name == nil) {
            sqlite3_bind_null(statement, 5);
        } else {
            sqlite3_bind_text(statement, 5, [record.name UTF8String], -1, SQLITE_STATIC);
        }
        sqlite3_bind_int(statement, 6, [record.categoryID intValue]);
        sqlite3_bind_double(statement, 7, record.labelX);
        sqlite3_bind_double(statement, 8, record.labelY);
        sqlite3_bind_int(statement, 9, record.symbolID);
        sqlite3_bind_int(statement, 10, record.floorNumber);
        sqlite3_bind_text(statement, 11, [record.floorName UTF8String], -1, SQLITE_STATIC);
        
        
        int layer;
        // Room Layer
        if (record.layer == 2) {
            layer = POI_ROOM;
        }
        // Asset Layer
        else if (record.layer == 3) {
            layer = POI_ASSET;
        }
        // Facility Layer
        else if (record.layer == 4) {
            layer = POI_FACILITY;
        }
        sqlite3_bind_int(statement, 12, layer);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"%@", errorString);
            return NO;
        }
    }
    sqlite3_finalize(statement);
    count =  sqlite3_exec(_database, "commit;",0,0,0);
    return count;
}

- (void)createTablesIfNotExists
{
    {
        NSString *poiSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@);", TABLE_POI,
                            [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_POI_0_PRIMARY_KEY],
                            [NSString stringWithFormat:@"%@ text not null", FIELD_POI_1_GEO_ID],
                            [NSString stringWithFormat:@"%@ text not null", FIELD_POI_2_POI_ID],
                            [NSString stringWithFormat:@"%@ text not null", FIELD_POI_3_BUILDING_ID],
                            [NSString stringWithFormat:@"%@ text not null", FIELD_POI_4_FLOOR_ID],
                            [NSString stringWithFormat:@"%@ text", FIELD_POI_5_NAME],
                            [NSString stringWithFormat:@"%@ integer not null", FIELD_POI_6_CATEGORY_ID],
                            [NSString stringWithFormat:@"%@ real not null", FIELD_POI_7_LABEL_X],
                            [NSString stringWithFormat:@"%@ real not null", FIELD_POI_8_LABEL_Y],
                            [NSString stringWithFormat:@"%@ integer not null", FIELD_POI_9_SYMBOL_ID],
                            [NSString stringWithFormat:@"%@ integer not null", FIELD_POI_10_FLOOR_NUMBER],
                            [NSString stringWithFormat:@"%@ text not null", FIELD_POI_11_FLOOR_NAME],
                            [NSString stringWithFormat:@"%@ integer not null", FIELD_POI_12_LAYER]
                            ];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [poiSql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create poi table failed!");
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
