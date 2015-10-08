//
//  RouteNetworkDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "RouteNetworkDBAdapter.h"

#import "FMDatabase.h"
#import "FMResultSet.h"

#import <geos.h>
#import <geos/geom.h>
#import <sstream>

#import "TYMapEnviroment.h"
#import "Geos2AgsConverter.h"

#import "TYLink.h"
#import "TYNode.h"

#import "RouteNetworkDBEntity.h"

#define TABLE_ROUTE_NODE @"RouteNode"
#define TABLE_ROUTE_LINK @"RouteLink"

using namespace std;

@interface RouteNetworkDBAdapter()
{
    FMDatabase *_database;
}

@end


@implementation RouteNetworkDBAdapter

- (id)initWithBuilding:(TYBuilding *)building
{
    self = [super init];
    if (self) {
        NSString *dbPath = [self getRouteDBPath:building];
        _database = [FMDatabase databaseWithPath:dbPath];
    }
    return self;
}

- (RouteNetworkDataset *)readRouteNetworkDataset
{
    return [[RouteNetworkDataset alloc] initWithNodes:[self getNodes] Links:[self getLinks]];
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

- (NSArray *)getLinks
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    stringstream s;
    WKBReader reader;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select linkID, Geometry, length, headNode, endNode, virtual, oneWay from %@", TABLE_ROUTE_LINK];
    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        LinkRecord *record = [[LinkRecord alloc] init];

        record.linkID = [rs intForColumn:@"linkID"];
        record.geometryData = [rs dataForColumn:@"Geometry"];
        s.clear();
        s.write((const char *)[record.geometryData bytes], [record.geometryData length]);
        record.line = (AGSPolyline *)[Geos2AgsConverter agsgeometryFromGeosGeometry:reader.read(s)];
        record.length = [rs doubleForColumn:@"length"];
        record.headNode = [rs intForColumn:@"headNode"];
        record.endNode = [rs intForColumn:@"endNode"];
        record.isVirtual = [rs boolForColumn:@"virtual"];
        record.isOneWay = [rs boolForColumn:@"oneWay"];
        
        [resultArray addObject:record];
    }
    
    return resultArray;
}

- (NSArray *)getNodes
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    stringstream s;
    WKBReader reader;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select nodeID, Geometry, links, virtual from %@", TABLE_ROUTE_NODE];
    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        NodeRecord *record = [[NodeRecord alloc] init];
        
        record.nodeID = [rs intForColumn:@"nodeID"];
        record.geometryData = [rs dataForColumn:@"Geometry"];
        s.clear();
        s.write((const char *)[record.geometryData bytes], [record.geometryData length]);
        record.pos = (AGSPoint *)[Geos2AgsConverter agsgeometryFromGeosGeometry:reader.read(s)];
        record.linksString = [rs stringForColumn:@"links"];
        record.isVirtual = [rs boolForColumn:@"virtual"];
        
        [resultArray addObject:record];
    }
    
    return resultArray;
}

@end

