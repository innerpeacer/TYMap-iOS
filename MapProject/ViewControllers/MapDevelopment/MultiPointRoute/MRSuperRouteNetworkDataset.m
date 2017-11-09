//
//  MRSuperRouteNetworkDataset.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRSuperRouteNetworkDataset.h"

@interface MRSuperRouteNetworkDataset()
{
    
}
@end

@implementation MRSuperRouteNetworkDataset

- (id)initWithNodes:(NSArray *)nodes Links:(NSArray *)links
{
    self = [super init];
    if (self) {
        _nodeArray = [NSMutableArray arrayWithArray:nodes];
        _allNodeDict = [NSMutableDictionary dictionary];
        for (int i = 0; i < nodes.count; ++i) {
            MRSuperNode *node = nodes[i];
            [_allNodeDict setObject:node forKey:@(node.nodeID)];
        }
        
        _linkArray = [NSMutableArray arrayWithArray:links];
        _allLinkDict = [NSMutableDictionary dictionary];
        for (int i = 0; i < links.count; ++i) {
            MRSuperLink *link = links[i];
            NSString *linkKey = [NSString stringWithFormat:@"%d%d", link.currentNodeID, link.nextNodeID];
            [_allLinkDict setObject:link forKey:linkKey];
        }
    }
    return self;
}

- (void)computePaths:(MRSuperNode *)source
{
    source.minDistance = 0;
    
    NSMutableArray *nodeQueue = [[NSMutableArray alloc] init];
    [nodeQueue addObject:source];
    
    while (nodeQueue.count > 0) {
        NSLog(@"nodeQueue: %d", (int)nodeQueue.count);
        [nodeQueue sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            MRSuperNode *node1 = (MRSuperNode *)obj1;
            MRSuperNode *node2 = (MRSuperNode *)obj2;
            return node1.minDistance > node2.minDistance;
        }];
        
        MRSuperNode *u = nodeQueue[0];
        [nodeQueue removeObjectAtIndex:0];
        
        for (MRSuperLink *e in u.adjacencies) {
            MRSuperNode *v = e.nextNode;
            double length = e.length;
            double distanceThroughU = u.minDistance + length;
            if (distanceThroughU < v.minDistance) {
                [nodeQueue removeObject:v];
                
                v.minDistance = distanceThroughU;
                v.previousNode = u;
                [nodeQueue addObject:v];
            }
        }
    }
}

- (AGSPolyline *)getShorestPathTo:(MRSuperNode *)target
{
    NSMutableArray *array = [NSMutableArray array];
    for (MRSuperNode *node = target; node != nil; node = node.previousNode) {
        [array addObject:node];
    }
    NSLog(@"array: %d", (int)array.count);
    NSArray *reverseArray = [[array reverseObjectEnumerator] allObjects];
    
    AGSMutablePolyline *resultLine = [[AGSMutablePolyline alloc] init];
    [resultLine addPathToPolyline];
    
    for (MRSuperNode *node in reverseArray) {
        if (node && node.previousNode) {
            
            NSString *key = [NSString stringWithFormat:@"%d%d", node.previousNode.nodeID, node.nodeID];
            MRSuperLink *link = [_allLinkDict objectForKey:key];
            for (int i = 0; i < [link.line numPointsInPath:0]; ++i) {
                [resultLine addPointToPath:[link.line pointOnPath:0 atIndex:i]];
            }
        }
    }
    
    AGSPolyline *result = (AGSPolyline *)[[AGSGeometryEngine defaultGeometryEngine] simplifyGeometry:resultLine];
    return result;
}

- (AGSPolyline *)getShorestPathFrom:(MRSuperNode *)start To:(MRSuperNode *)end
{
    [self reset];
    
    [self computePaths:start];
    AGSPolyline *nodePath = [self getShorestPathTo:end];
    
    if (nodePath.numPoints == 0) {
        return nil;
    }
    
    AGSMutablePolyline *path = [[AGSMutablePolyline alloc] init];
    [path addPathToPolyline];
    
    for (int i = 0; i < [nodePath numPointsInPath:0]; ++i) {
        [path addPointToPath:[nodePath pointOnPath:0 atIndex:i]];
    }
    return path;
}

- (void)reset
{
    for (MRSuperNode *node in _nodeArray) {
        [node reset];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d Links and %d Nodes", (int)(_linkArray.count), (int)(_nodeArray.count)];
}
@end
