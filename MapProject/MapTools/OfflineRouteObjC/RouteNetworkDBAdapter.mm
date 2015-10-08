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

#define TABLE_ROUTE_NODE @"RouteNode"
#define TABLE_ROUTE_LINK @"RouteLink"

using namespace std;

@interface RouteNetworkDBAdapter()
{
    FMDatabase *_database;
    
    NSMutableDictionary *nodeDictionary;
    NSMutableDictionary *linkDictionary;
    NSMutableDictionary *nodeLinkDictionary;
    
    NSMutableArray *linkArray;
    NSMutableArray *virtualLinkArray;
    NSMutableArray *nodeArray;
    NSMutableArray *virtualNodeArray;
}

@end


@implementation RouteNetworkDBAdapter

- (id)initWithBuilding:(TYBuilding *)building
{
    self = [super init];
    if (self) {
        NSString *dbPath = [self getRouteDBPath:building];
        _database = [FMDatabase databaseWithPath:dbPath];
        
        nodeDictionary = [NSMutableDictionary dictionary];
        linkDictionary = [NSMutableDictionary dictionary];
        nodeLinkDictionary = [NSMutableDictionary dictionary];
        
        linkArray = [NSMutableArray array];
        virtualLinkArray = [NSMutableArray array];
        nodeArray = [NSMutableArray array];
        virtualNodeArray = [NSMutableArray array];
    }
    return self;
}

- (RouteNetworkDataset *)readRouteNetworkDataset
{
    [nodeLinkDictionary removeAllObjects];
    [linkDictionary removeAllObjects];
    [nodeLinkDictionary removeAllObjects];
    
    [linkArray removeAllObjects];
    [virtualLinkArray removeAllObjects];
    [nodeArray removeAllObjects];
    [virtualNodeArray removeAllObjects];

    
    [self getLinks];
    [self getNodes];
    [self processNodesAndLinks];
    
    RouteNetworkDataset *dataset = [[RouteNetworkDataset alloc] initWithNodes:nodeArray VirtualNodes:virtualNodeArray Links:linkArray VirtualLinks:virtualLinkArray];
//    dataset.allNodeArray = nodeDictionary.allValues;
    dataset.allNodeDict = nodeDictionary;
//    dataset.allLinkArray = linkDictionary.allValues;
    dataset.allLinkDict = linkDictionary;
    
    return dataset;
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

- (void)processNodesAndLinks
{
    for (TYLink *link in linkDictionary.allValues) {
        TYNode *headNode = [nodeDictionary objectForKey:@(link.currentNodeID)];
        [headNode addLink:link];
        link.nextNode = [nodeDictionary objectForKey:@(link.nextNodeID)];
    }
}

- (void)getLinks
{
    stringstream s;
    WKBReader reader;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select linkID, Geometry, length, headNode, endNode, virtual, oneWay from %@", TABLE_ROUTE_LINK];
    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        int linkID = [rs intForColumn:@"linkID"];
        NSData *geometryData = [rs dataForColumn:@"Geometry"];
        s.clear();
        s.write((const char *)[geometryData bytes], [geometryData length]);
        AGSPolyline *line = (AGSPolyline *)[Geos2AgsConverter agsgeometryFromGeosGeometry:reader.read(s)];
        double length = [rs doubleForColumn:@"length"];
        int headNode = [rs intForColumn:@"headNode"];
        int endNode = [rs intForColumn:@"endNode"];
        BOOL isVirtual = [rs boolForColumn:@"virtual"];
        BOOL isOneWay = [rs boolForColumn:@"oneWay"];
        
        TYLink *forwardLink = [[TYLink alloc] initWithLinkID:linkID isVirtual:isVirtual];
        forwardLink.currentNodeID = headNode;
        forwardLink.nextNodeID = endNode;
        forwardLink.length = length;
        forwardLink.line = line;
        NSString *forwardLinkKey = [NSString stringWithFormat:@"%d%d", forwardLink.currentNodeID, forwardLink.nextNodeID];
        [linkDictionary setObject:forwardLink forKey:forwardLinkKey];
        
        if (isVirtual) {
            [virtualLinkArray addObject:forwardLink];
        } else {
            [linkArray addObject:forwardLink];
        }
        
        if (!isOneWay) {
            TYLink *reverseLink = [[TYLink alloc] initWithLinkID:linkID isVirtual:isVirtual];
            reverseLink.currentNodeID = endNode;
            reverseLink.nextNodeID = headNode;
            reverseLink.length = length;
            reverseLink.line = line;
            NSString *reverseLinkKey = [NSString stringWithFormat:@"%d%d", reverseLink.currentNodeID, reverseLink.nextNodeID];
            [linkDictionary setObject:reverseLink forKey:reverseLinkKey];
            
            if (isVirtual) {
                [virtualLinkArray addObject:reverseLink];
            } else {
                [linkArray addObject:reverseLink];
            }

        }
    }
}

- (void)getNodes
{
    stringstream s;
    WKBReader reader;
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select nodeID, Geometry, links, virtual from %@", TABLE_ROUTE_NODE];
    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        int nodeID = [rs intForColumn:@"nodeID"];
        NSData *geometryData = [rs dataForColumn:@"Geometry"];
        s.clear();
        s.write((const char *)[geometryData bytes], [geometryData length]);
        AGSPoint *pos = (AGSPoint *)[Geos2AgsConverter agsgeometryFromGeosGeometry:reader.read(s)];
        NSString *linksString = [rs stringForColumn:@"links"];
        BOOL isVirtual = [rs boolForColumn:@"virtual"];
        
        TYNode *node = [[TYNode alloc] initWithNodeID:nodeID isVirtual:isVirtual];
        node.pos = pos;
        
        [nodeDictionary setObject:node forKey:@(nodeID)];
        [nodeLinkDictionary setObject:linksString forKey:@(nodeID)];
        
        if (isVirtual) {
            [virtualNodeArray addObject:node];
        } else {
            [nodeArray addObject:node];
        }
    }
}


@end
