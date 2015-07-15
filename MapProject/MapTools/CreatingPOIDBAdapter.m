//
//  CreatingPOIDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/3/10.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "CreatingPOIDBAdapter.h"
#import "FMDatabase.h"
#import "TYPoi.h"

@interface CreatingPOIDBAdapter()
{
    FMDatabase *database;
}

@end


#define TABLE_POI @"POI"

#define FIELD_GEO_ID @"GEO_ID"
#define FIELD_POI_ID @"POI_ID"
#define FIELD_BUILDING_ID @"BUILDING_ID"
#define FIELD_FLOOR_ID @"FLOOR_ID"
#define FIELD_NAME @"NAME"
#define FIELD_CATEGORY_ID @"CATEGORY_ID"
#define FIELD_COLOR @"COLOR"
#define FIELD_FLOOR_INDEX @"FLOOR_INDEX"
#define FIELD_FLOOR_NAME @"FLOOR_NAME"
#define FIELD_LABEL_X @"LABEL_X"
#define FIELD_LABEL_Y @"LABEL_Y"
#define FIELD_POI_LAYER @"LAYER"

@implementation CreatingPOIDBAdapter

static CreatingPOIDBAdapter *_sharedDBAdapter;
static NSString *_currentBuildingID;

+ (CreatingPOIDBAdapter *)sharedDBAdapter:(NSString *)buildingID
{
    if (_currentBuildingID == nil || ![_currentBuildingID isEqualToString:buildingID]) {
        _sharedDBAdapter = [[CreatingPOIDBAdapter alloc] initWithDBFile:buildingID];
        _currentBuildingID = buildingID;
    }
    return _sharedDBAdapter;
}

- (id)initWithDBFile:(NSString *)buildingID
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", buildingID, @"POI.db"]];
        database = [FMDatabase databaseWithPath:dbPath];
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
    NSString *sql = @"CREATE TABLE POI (_id integer PRIMARY KEY, GEO_ID text, POI_ID text, BUILDING_ID text, FLOOR_ID text,  NAME text, CATEGORY_ID integer, LABEL_X double, LABEL_Y double, COLOR integer, FLOOR_INDEX integer, FLOOR_NAME text, LAYER integer);";
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

- (BOOL)insertPOIWithGeoID:(NSString *)gid poiID:(NSString *)pid buildingID:(NSString *)bid floorID:(NSString *)fid name:(NSString *)name categoryID:(NSNumber *)cid labelX:(NSNumber *)x labelY:(NSNumber *)y color:(NSNumber *)color floorIndex:(NSNumber *)fIndex floorName:(NSString *)fName layer:(NSNumber *)layer
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"Insert into %@", TABLE_POI];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *fields = [NSString stringWithFormat:@" ( %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) ", FIELD_GEO_ID, FIELD_POI_ID, FIELD_BUILDING_ID, FIELD_FLOOR_ID, FIELD_NAME, FIELD_CATEGORY_ID, FIELD_LABEL_X, FIELD_LABEL_Y, FIELD_COLOR, FIELD_FLOOR_INDEX, FIELD_FLOOR_NAME, FIELD_POI_LAYER];
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
