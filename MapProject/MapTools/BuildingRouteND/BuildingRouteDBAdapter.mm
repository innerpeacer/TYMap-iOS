//
//  BuildingRouteDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "BuildingRouteDBAdapter.h"

#import <geos.h>
#import <geos/geom.h>

#import "FMDatabase.h"
#import "FMResultSet.h"

#import "TYMapEnviroment.h"
#import "IPMapFileManager.h"
#import "IPMapDBConstants.h"

@interface BuildingRouteDBAdapter()
{
    FMDatabase *_database;
}

@end

@implementation BuildingRouteDBAdapter

- (id)initWithBuilding:(TYBuilding *)building
{
    self = [super init];
    if (self) {
        NSString *dbPath = [IPMapFileManager getMapDataDBPath:building];
        _database = [FMDatabase databaseWithPath:dbPath];
        [self checkDatabase];
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

- (BOOL)existTable:(NSString *)table
{
    if (!table) return NO;
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'", table];
    FMResultSet *set = [_database executeQuery:sql];
    if([set next]) {
        NSInteger count = [set intForColumnIndex:0];
        if (count > 0) return YES;
        else return NO;
    }
    return NO;
}

- (void)checkDatabase
{
    [_database open];
    if (![self existTable:TABLE_ROUTE_LINK]) {
        [self createRouteLinkTable];
    }
    
    if (![self existTable:TABLE_ROUTE_NODE]) {
        [self createRouteNodeTable];
    }
}

- (BOOL)createRouteLinkTable
{
    NSString *sql =  [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@)", TABLE_ROUTE_LINK,
                      [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_ROUTE_LINK_0_PRIMARY_KEY],
                      [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_LINK_1_LINK_ID],
                      [NSString stringWithFormat:@"%@ blob not null", FIELD_ROUTE_LINK_2_GEOMETRY],
                      [NSString stringWithFormat:@"%@ real not null", FIELD_ROUTE_LINK_3_LENGTH],
                      [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_LINK_4_HEAD_NODE],
                      [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_LINK_5_END_NODE],
                      [NSString stringWithFormat:@"%@ bool not null", FIELD_ROUTE_LINK_6_VIRTUAL],
                      [NSString stringWithFormat:@"%@ bool not null", FIELD_ROUTE_LINK_7_ONE_WAY]];
    if ([_database executeUpdate:sql]) {
        return YES;
    }
    return NO;
}

- (BOOL)createRouteNodeTable
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@)", TABLE_ROUTE_NODE,
                     [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_ROUTE_NODE_0_PRIMARY_KEY],
                     [NSString stringWithFormat:@"%@ integer not null", FIELD_ROUTE_NODE_1_NODE_ID],
                     [NSString stringWithFormat:@"%@ blob not null", FIELD_ROUTE_NODE_2_GEOMETRY],
                     [NSString stringWithFormat:@"%@ bool not null", FIELD_ROUTE_NODE_3_VIRTUAL]];
    if ([_database executeUpdate:sql]) {
        return YES;
    }
    return NO;
}

- (BOOL)eraseRouteLinkTable
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", TABLE_ROUTE_LINK];
    return [_database executeUpdate:sql];
}

- (BOOL)eraseRouteNodeTable
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", TABLE_ROUTE_NODE];
    return [_database executeUpdate:sql];
}

- (BOOL)insertNodeWithID:(int)nodeID Geometry:(NSData *)geometry Virtual:(BOOL)isVirtual
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"Insert into %@", TABLE_ROUTE_NODE];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    NSString *fields = [NSString stringWithFormat:@" (%@, %@, %@) ", FIELD_ROUTE_NODE_1_NODE_ID, FIELD_ROUTE_NODE_2_GEOMETRY, FIELD_ROUTE_NODE_3_VIRTUAL];
    NSString *values = @" (?, ?, ?)";
    
    [arguments addObject:@(nodeID)];
    [arguments addObject:geometry];
    [arguments addObject:@(isVirtual)];
    
    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [_database executeUpdate:sql withArgumentsInArray:arguments];
}

- (BOOL)insertLinkWithID:(int)linkID Geometry:(NSData *)geometry Length:(double)length Virtual:(BOOL)isVirtual HeadNode:(int)head EndNode:(int)end OneWay:(BOOL)oneWay
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"Insert into %@", TABLE_ROUTE_LINK];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    NSString *fields = [NSString stringWithFormat:@" (%@, %@, %@, %@, %@, %@, %@) ", FIELD_ROUTE_LINK_1_LINK_ID, FIELD_ROUTE_LINK_2_GEOMETRY, FIELD_ROUTE_LINK_3_LENGTH, FIELD_ROUTE_LINK_4_HEAD_NODE, FIELD_ROUTE_LINK_5_END_NODE, FIELD_ROUTE_LINK_6_VIRTUAL, FIELD_ROUTE_LINK_7_ONE_WAY];
    
    NSString *values = @" (?, ?, ?, ?, ?, ?, ?)";
    
    [arguments addObject:@(linkID)];
    [arguments addObject:geometry];
    [arguments addObject:@(length)];
    [arguments addObject:@(head)];
    [arguments addObject:@(end)];
    [arguments addObject:@(isVirtual)];
    [arguments addObject:@(oneWay)];
    
    [sql appendFormat:@" %@ VALUES %@", fields, values];
    return [_database executeUpdate:sql withArgumentsInArray:arguments];
}

- (BOOL)insertNode:(TYBuildingNode *)node
{
    return [self insertNodeWithID:node.nodeID Geometry:node.geometryData Virtual:node.isVirtual];
}

- (BOOL)insertLink:(TYBuildingLink *)link
{
    return [self insertLinkWithID:link.linkID Geometry:link.geometryData Length:link.length Virtual:link.isVirtual HeadNode:link.headNodeID EndNode:link.endNodeID OneWay:link.isOneWay];
}

@end
