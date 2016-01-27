//
//  WebSymbolDBAdpater.m
//  MapProject
//
//  Created by innerpeacer on 16/1/27.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "WebSymbolDBAdpater.h"
#import "IPMapDBConstants.h"
#import <sqlite3.h>
#import "WebMapFields.h"
#import "SymbolRecord.h"

@interface WebSymbolDBAdpater()
{
    sqlite3 *_database;
    NSString *dbPath;
}

@end

@implementation WebSymbolDBAdpater

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        dbPath = path;
    }
    return self;
}

- (NSDictionary *)readIconSymbols
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@ from %@", FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID, FIELD_MAP_SYMBOL_ICON_2_ICON, TABLE_MAP_SYMBOL_ICON_SYMBOL];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int symbolID = sqlite3_column_int(statement, 0);
            NSString *icon = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            IconSymbolRecord *record = [[IconSymbolRecord alloc] init];
            record.symbolID = symbolID;
            record.icon = icon;
            [resultDict setObject:record forKey:@(symbolID)];
        }
    }
    sqlite3_finalize(statement);
    return resultDict;
}

- (NSDictionary *)readFillSymbols
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@ from %@", FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID, FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR, FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR, FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH, TABLE_MAP_SYMBOL_FILL_SYMBOL];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int symbolID = sqlite3_column_int(statement, 0);
            NSString *fill = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *outline = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            if (fill.length < 9 || outline.length < 9) {
                continue;
            }
            
            float lineWidth = sqlite3_column_double(statement, 3);
            
            FillSymbolRecord *record = [[FillSymbolRecord alloc] init];
            record.symbolID = symbolID;
            record.fillColor = fill;
            record.outlineColor = outline;
            record.lineWidth = lineWidth;
            [resultDict setObject:record forKey:@(symbolID)];
        }
    }
    sqlite3_finalize(statement);
    
    return resultDict;
} 

- (BOOL)open
{
    if (sqlite3_open([dbPath UTF8String], &_database) == SQLITE_OK) {
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
