//
//  TYSyncSymbolRecord.m
//  MapProject
//
//  Created by innerpeacer on 15/12/15.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPSyncSymbolRecord.h"
#import "IPMapDBConstants.h"

@implementation IPSyncFillSymbolRecord

+ (IPSyncFillSymbolRecord *)parseFillSymbolRecord:(NSDictionary *)recordObject
{
    IPSyncFillSymbolRecord *record = [[IPSyncFillSymbolRecord alloc] init];
    record.symbolID = [recordObject[FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID] intValue];
    record.fillColor = recordObject[FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR];
    record.outlineColor = recordObject[FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR];
    record.lineWidth = [recordObject[FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH] doubleValue];
    return record;
}

+ (NSDictionary *)buildFillSymbolObject:(IPSyncFillSymbolRecord *)record
{
    NSMutableDictionary *recordOjbect = [NSMutableDictionary dictionary];
    [recordOjbect setObject:@(record.symbolID) forKey:FIELD_MAP_SYMBOL_FILL_1_SYMBOL_ID];
    [recordOjbect setObject:record.fillColor forKey:FIELD_MAP_SYMBOL_FILL_2_FILL_COLOR];
    [recordOjbect setObject:record.outlineColor forKey:FIELD_MAP_SYMBOL_FILL_3_OUTLINE_COLOR];
    [recordOjbect setObject:@(record.lineWidth) forKey:FIELD_MAP_SYMBOL_FILL_4_LINE_WIDTH];
    return recordOjbect;
}

@end

@implementation IPSyncIconSymbolRecord

+ (IPSyncIconSymbolRecord *)parseIconSymbolRecord:(NSDictionary *)recordObject
{
    IPSyncIconSymbolRecord *record = [[IPSyncIconSymbolRecord alloc] init];
    record.symbolID = [recordObject[FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID] intValue];
    record.icon = recordObject[FIELD_MAP_SYMBOL_ICON_2_ICON];
    return record;
}

+ (NSDictionary *)buildIconSymbolObject:(IPSyncIconSymbolRecord *)record
{
    NSMutableDictionary *recordObject = [NSMutableDictionary dictionary];
    [recordObject setObject:@(record.symbolID) forKey:FIELD_MAP_SYMBOL_ICON_1_SYMBOL_ID];
    [recordObject setObject:record.icon forKey:FIELD_MAP_SYMBOL_ICON_2_ICON];
    return recordObject;
}

@end