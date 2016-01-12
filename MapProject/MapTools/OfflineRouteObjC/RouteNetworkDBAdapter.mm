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
#import "IPMapDBConstants.h"

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
    NSString *dbName = [NSString stringWithFormat:@"%@.tymap", building.buildingID];
    return [[TYMapEnvironment getBuildingDirectory:building] stringByAppendingPathComponent:dbName];
}

- (NSArray *)getLinks
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    stringstream s;
    WKBReader reader;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select LINK_ID, GEOMETRY, LENGTH, HEAD_NODE, END_NODE, VIRTUAL, ONE_WAY from %@", TABLE_ROUTE_LINK];
    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        LinkRecord *record = [[LinkRecord alloc] init];

        record.linkID = [rs intForColumn:FIELD_ROUTE_LINK_1_LINK_ID];
        record.geometryData = [rs dataForColumn:FIELD_ROUTE_LINK_2_GEOMETRY];
        s.clear();
        s.write((const char *)[record.geometryData bytes], [record.geometryData length]);
        record.line = (AGSPolyline *)[Geos2AgsConverter agsgeometryFromGeosGeometry:reader.read(s)];
        record.length = [rs doubleForColumn:FIELD_ROUTE_LINK_3_LENGTH];
        record.headNode = [rs intForColumn:FIELD_ROUTE_LINK_4_HEAD_NODE];
        record.endNode = [rs intForColumn:FIELD_ROUTE_LINK_5_END_NODE];
        record.isVirtual = [rs boolForColumn:FIELD_ROUTE_LINK_6_VIRTUAL];
        record.isOneWay = [rs boolForColumn:FIELD_ROUTE_LINK_7_ONE_WAY];
        
        [resultArray addObject:record];
    }
    
    return resultArray;
}

- (NSArray *)getNodes
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    stringstream s;
    WKBReader reader;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select NODE_ID, GEOMETRY, VIRTUAL from %@", TABLE_ROUTE_NODE];
    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        NodeRecord *record = [[NodeRecord alloc] init];
        
        record.nodeID = [rs intForColumn:FIELD_ROUTE_NODE_1_NODE_ID];
        record.geometryData = [rs dataForColumn:FIELD_ROUTE_NODE_2_GEOMETRY];
        s.clear();
        s.write((const char *)[record.geometryData bytes], [record.geometryData length]);
        record.pos = (AGSPoint *)[Geos2AgsConverter agsgeometryFromGeosGeometry:reader.read(s)];
        record.isVirtual = [rs boolForColumn:FIELD_ROUTE_NODE_3_VIRTUAL];
        
        [resultArray addObject:record];
    }
    
    return resultArray;
}

@end

