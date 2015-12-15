//
//  TYSymbolDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYSymbolDBAdapter.h"
#import "FMDatabase.h"
#import "TYMapDBConstants.h"

@interface TYSymbolDBAdapter()
{
    FMDatabase *db;
    NSString *dbPath;
}

@end

@implementation TYSymbolDBAdapter

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        dbPath = path;
        db = [FMDatabase databaseWithPath:dbPath];
    }
    return self;
}

- (NSDictionary *)readIconSymbols
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@ from %@", FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID, FIELD_MAP_SYMBOL_ICON_2_ICON, TABLE_MAP_SYMBOL_ICON_SYMBOL];
    FMResultSet *rs = [db executeQuery:sql];
    
    while ([rs next]) {
        int symbolID = [rs intForColumn:FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID];
        NSString *icon = [rs stringForColumn:FIELD_MAP_SYMBOL_ICON_2_ICON];
        [resultDict setObject:icon forKey:@(symbolID)];
    }
    return resultDict;
}

- (NSDictionary *)readFillSymbols
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@ from %@", FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID, FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR, FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR, FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH, TABLE_MAP_SYMBOL_FILL_SYMBOL];
    FMResultSet *rs = [db executeQuery:sql];
    
    while ([rs next]) {
        int symbolID = [rs intForColumn:FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID];
        NSString *fill = [rs stringForColumn:FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR];
        NSString *outline = [rs stringForColumn:FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR];
        if (fill.length < 9 || outline.length < 9) {
            continue;
        }
        
        UIColor *fillColor = [self parseColor:fill];
        UIColor *outlineColor = [self parseColor:outline];
        float lineWidth = [rs doubleForColumn:FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH];
        
        AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbolWithColor:fillColor outlineColor:outlineColor];
        sfs.outline.width = lineWidth;
        [resultDict setObject:sfs forKey:@(symbolID)];
    }
    return resultDict;
}

- (BOOL)open
{
    return [db open];
}

- (BOOL)close
{
    return [db close];
}

/**
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
