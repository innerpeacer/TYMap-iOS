//
//  ShpRouteDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "ShpRouteDBAdapter.h"

#import "ShpRouteDBRecord.h"

#import "FMDatabase.h"
#import "FMResultSet.h"

@interface ShpRouteDBAdapter()
{
    FMDatabase *_database;
}

@end

@implementation ShpRouteDBAdapter

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _database = [FMDatabase databaseWithPath:path];
    }
    return self;
}


- (BOOL)open
{
    return [_database open];
}

- (BOOL)close
{
    return [_database close];
}

- (NSArray *)readAllNodeShpRouteRecords:(NSString *)table
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
//    NSMutableString *sql = [NSMutableString stringWithFormat:@"select GEOMETRY, objectid from %@", table];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select GEOMETRY, OGC_FID from %@", table];

    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        ShpRouteDBRecord *record = [[ShpRouteDBRecord alloc] init];
        record.geometryData = [rs dataForColumn:@"GEOMETRY"];
        record.geometryID = [rs intForColumn:@"OGC_FID"];
        [resultArray addObject:record];
    }
    return resultArray;
}

- (NSArray *)readAllLinkShpRouteRecords:(NSString *)table
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
//    NSMutableString *sql = [NSMutableString stringWithFormat:@"select GEOMETRY, objectid, oneway from %@", table];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select GEOMETRY, OGC_FID, oneway from %@", table];

    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        ShpRouteDBRecord *record = [[ShpRouteDBRecord alloc] init];
        record.geometryData = [rs dataForColumn:@"GEOMETRY"];
        record.geometryID = [rs intForColumn:@"OGC_FID"];
        record.oneWay = [rs boolForColumn:@"oneway"];
        [resultArray addObject:record];
    }
    return resultArray;
}

//- (NSArray *)readAllShpRouteRecords:(NSString *)table
//{
//    NSMutableArray *resultArray = [NSMutableArray array];
//    
//    NSMutableString *sql = [NSMutableString stringWithFormat:@"select GEOMETRY, objectid from %@", table];
//    FMResultSet *rs = [_database executeQuery:sql];
//    while ([rs next]) {
//        ShpRouteDBRecord *record = [[ShpRouteDBRecord alloc] init];
//        record.geometryData = [rs dataForColumn:@"GEOMETRY"];
//        record.geometryID = [rs intForColumn:@"objectid"];
//        [resultArray addObject:record];
//    }
//    return resultArray;
//}
@end
