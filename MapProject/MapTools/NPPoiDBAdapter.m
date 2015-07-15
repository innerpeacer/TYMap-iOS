
//
//  NPPoiDBAdapter.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPPoiDBAdapter.h"
#import "FMDatabase.h"

@interface NPPoiDBAdapter()
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

@implementation NPPoiDBAdapter

static NPPoiDBAdapter *_sharedDBAdapter;
static NSString *_currentBuildingID;

+ (NPPoiDBAdapter *)sharedDBAdapter:(NSString *)buildingID
{
    if (_currentBuildingID == nil || ![_currentBuildingID isEqualToString:buildingID]) {
        _sharedDBAdapter = [[NPPoiDBAdapter alloc] initWithDBFile:buildingID];
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
    }
    return self;
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
