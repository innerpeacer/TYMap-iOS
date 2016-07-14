//
//  TYSymbolDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPSymbolDBAdapter.h"
#import "IPMapDBConstants.h"
#import <sqlite3.h>

@interface IPSymbolDBAdapter()
{
    sqlite3 *_database;
    NSString *dbPath;
}

@end

@implementation IPSymbolDBAdapter

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
            [resultDict setObject:icon forKey:@(symbolID)];
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
            
            UIColor *fillColor = [self parseColor:fill];
            UIColor *outlineColor = [self parseColor:outline];
            float lineWidth = sqlite3_column_double(statement, 3);
            
            AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbolWithColor:fillColor outlineColor:outlineColor];
            sfs.outline.width = lineWidth;
            [resultDict setObject:sfs forKey:@(symbolID)];
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

/*
 *  从字符串中解析颜色值
 *
 *  @param colorString 颜色字符串，格式："#AARRGGBB"
 *
 *  @return 颜色值
 */
- (UIColor *)parseColor:(NSString *)colorString
{
    float alpha = strtoul([[colorString substringWithRange:NSMakeRange(1, 2)] UTF8String], 0, 16) / 255.0f;
    float red = strtoul([[colorString substringWithRange:NSMakeRange(3, 2)] UTF8String], 0, 16) / 255.0f;
    float green = strtoul([[colorString substringWithRange:NSMakeRange(5, 2)] UTF8String], 0, 16) / 255.0f;
    float blue = strtoul([[colorString substringWithRange:NSMakeRange(7, 2)] UTF8String], 0, 16) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
