//
//  OriginalSymbolDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "OriginalSymbolDBAdapter.h"
#import "FMDatabase.h"
#import "IPMapDBConstants.h"
#import "SymbolRecord.h"

@interface OriginalSymbolDBAdapter()
{
    FMDatabase *db;
    NSString *_dbPath;
}

@end

@implementation OriginalSymbolDBAdapter

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _dbPath = path;
        db = [FMDatabase databaseWithPath:_dbPath];
    }
    return self;
}

- (BOOL)open
{
    return [db open];
}

- (BOOL)close
{
    return [db close];
}


- (NSArray *)getAllFillSymbols
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@ from %@", FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID, FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR, FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR, FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH, TABLE_MAP_SYMBOL_FILL_SYMBOL];
    FMResultSet *rs = [db executeQuery:sql];

    while ([rs next]) {
        FillSymbolRecord *record = [[FillSymbolRecord alloc] init];
        
        record.symbolID = [rs intForColumn:FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID];
        record.fillColor = [rs stringForColumn:FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR];
        record.outlineColor = [rs stringForColumn:FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR];
        record.lineWidth = [rs doubleForColumn:FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH];
        
        [resultArray addObject:record];
    }
    return resultArray;
}

- (NSArray *)getAllIconSymbols
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@ from %@", FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID, FIELD_MAP_SYMBOL_ICON_2_ICON, TABLE_MAP_SYMBOL_ICON_SYMBOL];
    FMResultSet *rs = [db executeQuery:sql];
    
    while ([rs next]) {
        IconSymbolRecord *record = [[IconSymbolRecord alloc] init];
        
        record.symbolID = [rs intForColumn:FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID];
        record.icon = [rs stringForColumn:FIELD_MAP_SYMBOL_ICON_2_ICON];
        
        [resultArray addObject:record];
    }
    return resultArray;
}

@end
