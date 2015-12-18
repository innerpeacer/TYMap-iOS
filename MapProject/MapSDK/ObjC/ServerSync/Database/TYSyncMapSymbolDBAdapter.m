//
//  TYSyncMapSymbolDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/12/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYSyncMapSymbolDBAdapter.h"
#import "TYMapDBConstants.h"

#include <sqlite3.h>

@interface TYSyncMapSymbolDBAdapter()
{
    sqlite3 *_database;
    NSString *dbPath;
}

@end

@implementation TYSyncMapSymbolDBAdapter

- (id)initWithPath:(NSString *)path;
{
    self = [super init];
    if (self) {
        dbPath = path;
    }
    return self;
}



- (BOOL)eraseSymbolTable
{
    return [self eraseFillSymbolTable] && [self eraseIconSymbolTable];
}

- (BOOL)eraseFillSymbolTable
{
    NSString *errorString = @"Error: failed to erase Fill Symbol Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAP_SYMBOL_FILL_SYMBOL];
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

- (BOOL)eraseIconSymbolTable
{
    NSString *errorString = @"Error: failed to erase Icon Symbol Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_MAP_SYMBOL_ICON_SYMBOL];
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

- (BOOL)insertFillSymbol:(TYSyncFillSymbolRecord *)fillRecord
{
    NSString *errorString = @"Error: failed to insert Fill Symbol into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@) values (?, ?, ?, ?)", TABLE_MAP_SYMBOL_FILL_SYMBOL, FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID, FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR, FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR, FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH];
    
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, fillRecord.symbolID);
    sqlite3_bind_text(statement, 2, [fillRecord.fillColor UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [fillRecord.outlineColor UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 4, fillRecord.lineWidth);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)insertIconSymbol:(TYSyncIconSymbolRecord *)iconRecord
{
    NSString *errorString = @"Error: failed to insert Icon Symbol into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@) values (?, ?)", TABLE_MAP_SYMBOL_ICON_SYMBOL, FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID, FIELD_MAP_SYMBOL_ICON_2_ICON];
    
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, iconRecord.symbolID);
    sqlite3_bind_text(statement, 2, [iconRecord.icon UTF8String], -1, SQLITE_STATIC);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (int)insertFillSymbols:(NSArray *)fillSymbols
{
    int count = 0;
    for (TYSyncFillSymbolRecord *fillRecord in fillSymbols) {
        BOOL success = [self insertFillSymbol:fillRecord];
        if (success) {
            ++count;
        }
    }
    return count;
}

- (int)insertIconSymbols:(NSArray *)iconSymbols
{
    int count = 0;
    for (TYSyncIconSymbolRecord *iconRecord in iconSymbols) {
        BOOL success = [self insertIconSymbol:iconRecord];
        if (success) {
            ++count;
        }
    }
    return count;
}

- (NSArray *)getAllFillSymbols
{
    NSMutableArray *fillSymbolArray = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSMutableString stringWithFormat:@"SELECT distinct %@,%@,%@,%@ FROM %@", FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID, FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR, FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR, FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH, TABLE_MAP_SYMBOL_FILL_SYMBOL];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int symbolID = sqlite3_column_int(statement, 0);
            NSString *fillColor = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *outlineColor = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            double linewidth = sqlite3_column_double(statement, 3);
            
            TYSyncFillSymbolRecord *record = [[TYSyncFillSymbolRecord alloc] init];
            record.symbolID = symbolID;
            record.fillColor = fillColor;
            record.outlineColor = outlineColor;
            record.lineWidth = linewidth;
            
            [fillSymbolArray addObject:record];
        }
    }
    sqlite3_finalize(statement);
    return fillSymbolArray;
}

- (NSArray *)getAllIconSymbols
{
    NSMutableArray *iconSymbolArray = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSMutableString stringWithFormat:@"SELECT distinct %@,%@ FROM %@", FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID, FIELD_MAP_SYMBOL_ICON_2_ICON, TABLE_MAP_SYMBOL_ICON_SYMBOL];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int symbolID = sqlite3_column_int(statement, 0);
            NSString *icon = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            TYSyncIconSymbolRecord *record = [[TYSyncIconSymbolRecord alloc] init];
            record.symbolID = symbolID;
            record.icon = icon;
            
            [iconSymbolArray addObject:record];
        }
    }
    sqlite3_finalize(statement);
    return iconSymbolArray;
}

- (void)createTablesIfNotExists
{
    {
        NSString *fillTableSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@)", TABLE_MAP_SYMBOL_FILL_SYMBOL,
                                  [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_MAP_SYMBOL_FILL_0_PRIMARY_KEY],
                                  [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR],
                                  [NSString stringWithFormat:@"%@ real not null", FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH]
                                  ];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [fillTableSql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create mapinfo table failed!");
            return;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    
    {
        NSString *iconTableSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@)", TABLE_MAP_SYMBOL_ICON_SYMBOL,
                                  [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_MAP_SYMBOL_ICON_0_PRIMARY_KEY],
                                  [NSString stringWithFormat:@"%@ integer not null", FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_MAP_SYMBOL_ICON_2_ICON]];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [iconTableSql UTF8String], -1, &statement, nil);
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
    if (sqlite3_open([dbPath UTF8String], &_database) == SQLITE_OK) {
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
