//
//  TYSyncMapRouteDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYSyncMapRouteDBAdapter.h"
#include <sqlite3.h>
#import "TYSyncRouteRecord.h"
#import "TYMapDBConstants.h"
#import "TYMapInfo.h"
@interface TYSyncMapRouteDBAdapter()
{
    sqlite3 *_database;
    NSString *_dbPath;
}

@end

@implementation TYSyncMapRouteDBAdapter

- (id)initWithPath:(NSString *)path;
{
    self = [super init];
    if (self) {
        _dbPath = path;
        
    }
    return self;
}

- (void)eraseRouteDataTable
{
    [self eraseRouteNodeTable];
    [self eraseRouteLinkTable];
}

- (BOOL)eraseRouteNodeTable
{
    NSString *errorString = @"Error: failed to erase route node Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_ROUTE_NODE];
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

- (BOOL)eraseRouteLinkTable
{
    NSString *errorString = @"Error: failed to erase route link Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_ROUTE_LINK];
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

- (BOOL)insertRouteNodeRecord:(TYSyncRouteNodeRecord *)record
{
    NSString *errorString = @"Error: failed to insert route node into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@) values ( ?, ?, ?)", TABLE_ROUTE_NODE, FIELD_ROUTE_NODE_1_NODE_ID, FIELD_ROUTE_NODE_2_GEOMETRY, FIELD_ROUTE_NODE_3_VIRTUAL];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, record.nodeID);
    sqlite3_bind_blob(statement, 2, (const void *)[record.geometryData bytes], (int)[record.geometryData length], SQLITE_STATIC);
    sqlite3_bind_int(statement, 3, record.isVirtual);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (int)insertRouteNodeRecords:(NSArray *)records
{
    int count = 0;
    for (TYSyncRouteNodeRecord *record in records) {
        BOOL success = [self insertRouteNodeRecord:record];
        if (success) {
            ++count;
        }
    }
    return count;
}

- (BOOL)insertRouteLinkRecord:(TYSyncRouteLinkRecord *)record
{
    NSString *errorString = @"Error: failed to insert route link into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@, %@) values ( ?, ?, ?, ?, ?, ?, ?)", TABLE_ROUTE_LINK, FIELD_ROUTE_LINK_1_LINK_ID, FIELD_ROUTE_LINK_2_GEOMETRY, FIELD_ROUTE_LINK_3_LENGTH, FIELD_ROUTE_LINK_4_HEAD_NODE, FIELD_ROUTE_LINK_5_END_NODE, FIELD_ROUTE_LINK_6_VIRTUAL, FIELD_ROUTE_LINK_7_ONE_WAY];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, record.linkID);
    sqlite3_bind_blob(statement, 2, (const void *)[record.geometryData bytes], (int)[record.geometryData length], SQLITE_STATIC);
    sqlite3_bind_double(statement, 3, record.length);
    sqlite3_bind_int(statement, 4, record.headNode);
    sqlite3_bind_int(statement, 5, record.endNode);
    sqlite3_bind_int(statement, 6, record.isVirtual);
    sqlite3_bind_int(statement, 7, record.isOneWay);

    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;

}

- (int)insertRouteLinkRecords:(NSArray *)records
{
    int count = 0;
    for (TYSyncRouteLinkRecord *record in records) {
        BOOL success = [self insertRouteLinkRecord:record];
        if (success) {
            ++count;
        }
    }
    return count;
}

- (BOOL)updateRouteNodeRecord:(TYSyncRouteNodeRecord *)record
{
    NSString *errorString = @"Error: failed to update route node";
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@=?, %@=?, %@=? where %@=?", TABLE_ROUTE_NODE, FIELD_ROUTE_NODE_1_NODE_ID, FIELD_ROUTE_NODE_2_GEOMETRY, FIELD_ROUTE_NODE_3_VIRTUAL, FIELD_ROUTE_NODE_1_NODE_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, record.nodeID);
    sqlite3_bind_blob(statement, 2, (const void *)[record.geometryData bytes], (int)[record.geometryData length], SQLITE_STATIC);
    sqlite3_bind_int(statement, 3, record.isVirtual);
    sqlite3_bind_int(statement, 4, record.nodeID);

    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (void)updateRouteNodeRecords:(NSArray *)records
{
    for (TYSyncRouteNodeRecord *record in records) {
        [self updateRouteNodeRecord:record];
    }
}

- (BOOL)updateRouteLinkRecord:(TYSyncRouteLinkRecord *)record
{
    NSString *errorString = @"Error: failed to update route link";
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=? where %@=?", TABLE_ROUTE_LINK, FIELD_ROUTE_LINK_1_LINK_ID, FIELD_ROUTE_LINK_2_GEOMETRY, FIELD_ROUTE_LINK_3_LENGTH, FIELD_ROUTE_LINK_4_HEAD_NODE, FIELD_ROUTE_LINK_5_END_NODE, FIELD_ROUTE_LINK_6_VIRTUAL, FIELD_ROUTE_LINK_7_ONE_WAY, FIELD_ROUTE_LINK_1_LINK_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, record.linkID);
    sqlite3_bind_blob(statement, 2, (const void *)[record.geometryData bytes], (int)[record.geometryData length], SQLITE_STATIC);
    sqlite3_bind_double(statement, 3, record.length);
    sqlite3_bind_int(statement, 4, record.headNode);
    sqlite3_bind_int(statement, 5, record.endNode);
    sqlite3_bind_int(statement, 6, record.isVirtual);
    sqlite3_bind_int(statement, 7, record.isOneWay);
    sqlite3_bind_int(statement, 8, record.linkID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (void)updateRouteLinkRecords:(NSArray *)records
{
    for (TYSyncRouteLinkRecord *record in records) {
        [self updateRouteLinkRecord:record];
    }
}

- (BOOL)deleteRouteNodeRecord:(int)nodeID
{
    NSString *errorString = @"Error: failed to delete route node";
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", TABLE_ROUTE_NODE, FIELD_ROUTE_NODE_1_NODE_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, nodeID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)deleteRouteLinkRecord:(int)linkID
{
    NSString *errorString = @"Error: failed to delete route link";
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", TABLE_ROUTE_LINK, FIELD_ROUTE_LINK_1_LINK_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, linkID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (NSArray *)getAllRouteLinkRecords
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"select %@, %@, %@, %@, %@, %@, %@ from %@", FIELD_ROUTE_LINK_1_LINK_ID, FIELD_ROUTE_LINK_2_GEOMETRY, FIELD_ROUTE_LINK_3_LENGTH, FIELD_ROUTE_LINK_4_HEAD_NODE, FIELD_ROUTE_LINK_5_END_NODE, FIELD_ROUTE_LINK_6_VIRTUAL, FIELD_ROUTE_LINK_7_ONE_WAY, TABLE_ROUTE_LINK];
    const char *selectSql = [sql UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            TYSyncRouteLinkRecord *record = [[TYSyncRouteLinkRecord alloc] init];
            record.linkID = sqlite3_column_int(statement, 0);
            record.geometryData = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 1) length:sqlite3_column_bytes(statement, 1)];
            record.length = sqlite3_column_double(statement, 2);
            record.headNode = sqlite3_column_int(statement, 3);
            record.endNode = sqlite3_column_int(statement, 4);
            record.isVirtual = sqlite3_column_int(statement, 5);
            record.isOneWay = sqlite3_column_int(statement, 6);
            [array addObject:record];
        }
    }
    sqlite3_finalize(statement);
    return array;
}

- (NSArray *)getAllRouteNodeRecords
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"select %@, %@, %@ from %@", FIELD_ROUTE_NODE_1_NODE_ID, FIELD_ROUTE_NODE_2_GEOMETRY, FIELD_ROUTE_NODE_3_VIRTUAL, TABLE_ROUTE_NODE];
    const char *selectSql = [sql UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            TYSyncRouteNodeRecord *record = [[TYSyncRouteNodeRecord alloc] init];
            record.nodeID = sqlite3_column_int(statement, 0);
            record.geometryData = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 1) length:sqlite3_column_bytes(statement, 1)];
            record.isVirtual = sqlite3_column_int(statement, 2);
            
            [array addObject:record];
        }
    }
    sqlite3_finalize(statement);
    return array;
}

- (void)createTablesIfNotExists
{
    {
        NSString *routeLinkSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@)", TABLE_ROUTE_LINK,
                                [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_ROUTE_LINK_0_PRIMARY_KEY],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_LINK_1_LINK_ID],
                                [NSString stringWithFormat:@"%@ blob not null", FIELD_ROUTE_LINK_2_GEOMETRY],
                                [NSString stringWithFormat:@"%@ real not null", FIELD_ROUTE_LINK_3_LENGTH],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_LINK_4_HEAD_NODE],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_LINK_5_END_NODE],
                                [NSString stringWithFormat:@"%@ bool not null", FIELD_ROUTE_LINK_6_VIRTUAL],
                                [NSString stringWithFormat:@"%@ bool not null", FIELD_ROUTE_LINK_7_ONE_WAY]];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [routeLinkSql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create routelink table failed!");
            return;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    
    {
        NSString *routeNodeSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@)", TABLE_ROUTE_NODE,
                                [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_ROUTE_NODE_0_PRIMARY_KEY],
                                [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_NODE_1_NODE_ID],
                                [NSString stringWithFormat:@"%@ blob not null", FIELD_ROUTE_NODE_2_GEOMETRY],
                                [NSString stringWithFormat:@"%@ bool not null", FIELD_ROUTE_NODE_3_VIRTUAL]];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [routeNodeSql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create mapinfo table failed!");
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
