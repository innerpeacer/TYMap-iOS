//
//  CreatingPOIDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/3/10.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "CreatingPOIDBAdapter.h"
#import "FMDatabase.h"
#import "IPMapDBConstants.h"

@interface CreatingPOIDBAdapter()
{
    FMDatabase *database;
}

@end

@implementation CreatingPOIDBAdapter

- (id)initWithDBPath:(NSString *)path
{
    self = [super init];
    if (self) {
        database = [FMDatabase databaseWithPath:path];
        [self checkDatabase];
    }
    return self;
}

- (void)checkDatabase
{
    [database open];
    if (![self existTable:TABLE_POI]) {
        [self createPOITable];
    }
}

- (BOOL)createPOITable
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@);", TABLE_POI,
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
    if ([database executeUpdate:sql]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)existTable:(NSString *)table
{
    if (!table) {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",table];
    
    FMResultSet *set = [database executeQuery:sql];
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

- (BOOL)insertPOIWithGeoID:(NSString *)gid poiID:(NSString *)pid buildingID:(NSString *)bid floorID:(NSString *)fid name:(NSString *)name categoryID:(NSNumber *)cid labelX:(NSNumber *)x labelY:(NSNumber *)y color:(NSNumber *)color FloorNumber:(NSNumber *)fIndex floorName:(NSString *)fName layer:(NSNumber *)layer
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"Insert into %@", TABLE_POI];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" ( %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) ", FIELD_POI_1_GEO_ID, FIELD_POI_2_POI_ID, FIELD_POI_3_BUILDING_ID, FIELD_POI_4_FLOOR_ID, FIELD_POI_5_NAME, FIELD_POI_6_CATEGORY_ID, FIELD_POI_7_LABEL_X, FIELD_POI_8_LABEL_Y, FIELD_POI_9_SYMBOL_ID, FIELD_POI_10_FLOOR_NUMBER, FIELD_POI_11_FLOOR_NAME, FIELD_POI_12_LAYER];
    NSString *values = @" ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
    
    [arguments addObject:gid];
    [arguments addObject:pid];
    [arguments addObject:bid];
    [arguments addObject:fid];
    [arguments addObject:name==nil ? [NSNull null] : name];
    [arguments addObject:[NSString stringWithFormat:@"%@", cid]];
    [arguments addObject:[NSString stringWithFormat:@"%@", x]];
    [arguments addObject:[NSString stringWithFormat:@"%@", y]];
    [arguments addObject:color == nil ? [NSNull null] : [NSString stringWithFormat:@"%@", color]];
    [arguments addObject:[NSString stringWithFormat:@"%@", fIndex]];
    [arguments addObject:fName];
    [arguments addObject:layer];

    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [database executeUpdate:sql withArgumentsInArray:arguments];
}

- (BOOL)erasePOITable
{
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", TABLE_POI];
    return [database executeUpdate:sql];
}


#pragma mark DB operation

- (BOOL)open
{
    return [database open];
}

- (BOOL)close
{
    return [database close];
}



@end
