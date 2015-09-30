//
//  RouteNDBuildingTool.m
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "RouteNDBuildingTool.h"
#import "ShpRouteDataGroup.h"

#import "TYBuildingNode.h"
#import "TYBuildingLink.h"

#import "BuildingRouteDBAdapter.h"

@interface RouteNDBuildingTool()
{
    TYBuilding *building;
    ShpRouteDataGroup *shpDataGroup;
    
    NSMutableArray *allNodeArray;
    NSMutableArray *allLinkArray;
}

@end

@implementation RouteNDBuildingTool

- (id)initWithBuilding:(TYBuilding *)b
{
    self = [super init];
    if (self) {
        building = b;
        shpDataGroup = [[ShpRouteDataGroup alloc] initWithBuilding:building];
        
        allNodeArray = [[NSMutableArray alloc] init];
        allLinkArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)buildRouteNetworkDataset
{
    NSLog(@"buildRouteNetworkDataset");
    
    [allNodeArray removeAllObjects];
    [allNodeArray addObjectsFromArray:shpDataGroup.nodeArray];
    [allNodeArray addObjectsFromArray:shpDataGroup.virtualNodeArray];
    [allNodeArray addObjectsFromArray:shpDataGroup.junctionNodeArray];
    
    [allLinkArray removeAllObjects];
    [allLinkArray addObjectsFromArray:shpDataGroup.linkArray];
    [allLinkArray addObjectsFromArray:shpDataGroup.virtualLinkArray];
    
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    for (TYBuildingLink *link in allLinkArray) {
        AGSPoint *linkHeadPoint = [link.line pointOnPath:0 atIndex:0];
        AGSPoint *linkEndPoint = [link.line pointOnPath:0 atIndex:[link.line numPoints]-1];
    
        TYBuildingNode *headNode = nil;
        TYBuildingNode *endNode = nil;
        
        BOOL headFound = NO;
        BOOL endFound = NO;
        
        for (TYBuildingNode *node in allNodeArray) {
            double headDistance = [engine distanceFromGeometry:linkHeadPoint toGeometry:node.pos];
            double endDistance = [engine distanceFromGeometry:linkEndPoint toGeometry:node.pos];
            
            if (headDistance == 0) {
                headNode = node;
                headFound = YES;
            } else if (endDistance == 0) {
                endNode = node;
                endFound = YES;
            }
            
            if (headFound && endFound) {
                break;
            }
        }
        
        if (headFound) {
            link.headNodeID = headNode.nodeID;
            [headNode addLink:link];
        }
        
        if (endFound) {
            link.endNodeID = endNode.nodeID;
            [endNode addLink:link];
        }
    }
    
    [self writeNetworkDatasetToDatabase];
}

- (void)writeNetworkDatasetToDatabase
{
    BuildingRouteDBAdapter *db = [[BuildingRouteDBAdapter alloc] initWithBuilding:building];
    
    [db open];
    [db eraseRouteLinkTable];
    [db eraseRouteNodeTable];
    
    for (TYBuildingNode *node in allNodeArray) {
        [db insertNode:node];
    }
    
    for (TYBuildingLink *link in allLinkArray) {
        [db insertLink:link];
    }
    
    [db close];
}

@end
