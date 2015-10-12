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

#define TABLE_ROUTE_NODE @"RouteNode"
#define TABLE_ROUTE_LINK @"RouteLink"

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
        NSString *dbPath = [self getRouteDBPath:building];
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

- (NSString *)getRouteDBPath:(TYBuilding *)building
{
    NSString *dbName = [NSString stringWithFormat:@"%@_Route.db", building.buildingID];
    return [[TYMapEnvironment getBuildingDirectory:building] stringByAppendingPathComponent:dbName];
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
    NSString *sql = [NSString stringWithFormat:@"create table %@ (%@, %@, %@, %@, %@, %@, %@, %@) ", TABLE_ROUTE_LINK, @"_id integer primary key autoincrement", @"linkID integer not null", @"Geometry blob not null", @"length real not null", @"headNode integer not null", @"endNode integer not null", @"virtual bool not null", @"oneWay bool not null"];
    if ([_database executeUpdate:sql]) {
        return YES;
    }
    return NO;
}

- (BOOL)createRouteNodeTable
{
    NSString *sql = [NSString stringWithFormat:@"create table %@ (%@, %@, %@, %@)", TABLE_ROUTE_NODE, @"_id integer primary key autoincrement", @"nodeID integer not null", @"Geometry blob not null", @"virtual bool not null"];
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
    
    NSString *fields = [NSString stringWithFormat:@" (nodeID, Geometry, virtual) "];
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
    
    NSString *fields = [NSString stringWithFormat:@" (linkID, Geometry, length, headNode, endNode, virtual, oneWay) "];
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
