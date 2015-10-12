//
//  ShpRouteDataGroup.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "ShpRouteDataGroup.h"
#import "TYMapEnviroment.h"

#import "TYBuildingLink.h"
#import "TYBuildingNode.h"
#import "ShpRouteDBRecord.h"
#import "ShpRouteDBAdapter.h"

@interface ShpRouteDataGroup()
{
    TYBuilding *building;
    NSArray *dbArray;
    NSArray *tableArray;
}

@end

@implementation ShpRouteDataGroup

- (id)initWithBuilding:(TYBuilding *)b
{
    self = [super init];
    if (self) {
        building = b;
        dbArray = @[@"NODE", @"VIRTUAL_NODE", @"JUNCTION", @"LINK", @"VIRTUAL_LINK"];
        tableArray = @[@"node", @"virtual_node", @"junction", @"link", @"virtual_link"];

        self.nodeArray = [self readNodeDB];
        self.virtualNodeArray = [self readVirtualNodeDB];
        self.junctionNodeArray = [self readJunctionDB];
        
        self.linkArray = [self readLinkDB];
        self.virtualLinkArray = [self readVirtualLinkDB];
    }
    return self;
}

- (NSArray *)readNodeDB
{
    return [self readPointDB:1 Virtual:NO];
}

- (NSArray *)readVirtualNodeDB
{
    return [self readPointDB:2 Virtual:YES];
}

- (NSArray *)readJunctionDB
{
    return [self readPointDB:3 Virtual:NO];
}

- (NSArray *)readLinkDB
{
    return [self readPolylineDB:4 Virtual:NO];
}

- (NSArray *)readVirtualLinkDB
{
    return [self readPolylineDB:5 Virtual:YES];
}

- (NSArray *)readPolylineDB:(int)index Virtual:(BOOL)isVirtual
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    int offsetForID = [self getOffset:index];
    
//    NSArray *shpRecords = [self readShpRouteRecords:index];
    NSArray *shpRecords = [self readLinkShpRouteRecords:index];
    for (ShpRouteDBRecord *record in shpRecords) {
        AGSPolyline *line = (AGSPolyline *)[record getAgsGeometry];
        int gid = record.geometryID + offsetForID;
        double length = [record getGeosGeometry]->getLength();
        
        TYBuildingLink *l = [[TYBuildingLink alloc] initWithLinkID:gid isVirtual:isVirtual isOneWay:record.oneWay];
        l.line = line;
        l.length = length;
        l.geometryData = record.geometryData;
        
        [resultArray addObject:l];
    }
    return resultArray;
    
}

- (NSArray *)readPointDB:(int)index Virtual:(BOOL)isVirtual
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    int offsetForID = [self getOffset:index];
    
//    NSArray *shpRecords = [self readShpRouteRecords:index];
    NSArray *shpRecords = [self readNodeShpRouteRecords:index];
    for (ShpRouteDBRecord *record in shpRecords) {
        AGSPoint *point = (AGSPoint *)[record getAgsGeometry];
        int gid = record.geometryID + offsetForID;
        
        TYBuildingNode *n = [[TYBuildingNode alloc] initWithNodeID:gid isVirtual:isVirtual];
        n.pos = point;
        n.geometryData = record.geometryData;
        [resultArray addObject:n];
    }
    return resultArray;
}

//- (NSArray *)readShpRouteRecords:(int)index
//{
//    NSArray *result = nil;
//    ShpRouteDBAdapter *db = [[ShpRouteDBAdapter alloc] initWithPath:[self getDBPath:index]];
//    [db open];
//    result = [db readAllShpRouteRecords:[self getTableName:index]];
//    [db close];
//    return result;
//}

- (NSArray *)readNodeShpRouteRecords:(int)index
{
    NSArray *result = nil;
    ShpRouteDBAdapter *db = [[ShpRouteDBAdapter alloc] initWithPath:[self getDBPath:index]];
    [db open];
    result = [db readAllNodeShpRouteRecords:[self getTableName:index]];
    [db close];
    return result;
}

- (NSArray *)readLinkShpRouteRecords:(int)index
{
    NSArray *result = nil;
    ShpRouteDBAdapter *db = [[ShpRouteDBAdapter alloc] initWithPath:[self getDBPath:index]];
    [db open];
    result = [db readAllLinkShpRouteRecords:[self getTableName:index]];
    [db close];
    return result;
}

- (int)getOffset:(int)index
{
    return 10000 * index;
}

- (NSString *)getDBPath:(int)index
{
    NSString *dbName = [NSString stringWithFormat:@"%@_%@.db", building.buildingID, dbArray[index - 1]];
   return [[TYMapEnvironment getBuildingDirectory:building] stringByAppendingPathComponent:dbName];
}

- (NSString *)getTableName:(int)index
{
    return tableArray[index - 1];
}

@end
