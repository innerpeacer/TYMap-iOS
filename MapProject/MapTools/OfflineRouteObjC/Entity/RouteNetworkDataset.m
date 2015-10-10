//
//  RouteNetworkDataset.m
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "RouteNetworkDataset.h"
#import "RouteNetworkDBEntity.h"

@interface RouteNetworkDataset()
{
    AGSGeometryEngine *engine;
    
    NSMutableArray *tempStartNodeArray;
    NSMutableArray *tempStartLinkArray;
    NSMutableArray *replacedStartLinkArray;
    
    NSMutableArray *tempEndNodeArray;
    NSMutableArray *tempEndLinkArray;
    NSMutableArray *replacedEndLinkArray;
    
    int tempNodeID;
    int tempLinkID;
    
}

@end

@implementation RouteNetworkDataset

- (id)initWithNodes:(NSArray *)nodes Links:(NSArray *)links
{
    self = [super init];
    if (self) {
        engine = [AGSGeometryEngine defaultGeometryEngine];
        
        tempNodeID = 60000;
        tempLinkID = 80000;
        
        replacedStartLinkArray = [NSMutableArray array];
        replacedEndLinkArray = [NSMutableArray array];
        
        tempStartNodeArray = [NSMutableArray array];
        tempStartLinkArray = [NSMutableArray array];
        
        tempEndNodeArray = [NSMutableArray array];
        tempEndLinkArray = [NSMutableArray array];
        
        [self extractNodes:nodes];
        [self extractLinks:links];
        [self processNodesAndLinks];
        
        NSMutableArray *allLinkLines = [NSMutableArray array];
        for (TYLink *link in _linkArray) {
            [allLinkLines addObject:link.line];
        }
        _unionLine = (AGSPolyline *)[[AGSGeometryEngine defaultGeometryEngine] unionGeometries:allLinkLines];
    }
    return self;
}

- (void)extractNodes:(NSArray *)nodes
{
    _nodeArray = [NSMutableArray array];
    _virtualNodeArray = [NSMutableArray array];
    _allNodeDict = [NSMutableDictionary dictionary];
    
    for (NodeRecord *record in nodes) {
        TYNode *node = [[TYNode alloc] initWithNodeID:record.nodeID isVirtual:record.isVirtual];
        node.pos = record.pos;
        
        [_allNodeDict setObject:node forKey:@(record.nodeID)];
        
        if (record.isVirtual) {
            [_virtualNodeArray addObject:node];
        } else {
            [_nodeArray addObject:node];
        }
    }
}

- (void)extractLinks:(NSArray *)links
{
    _linkArray = [NSMutableArray array];
    _virtualLinkArray = [NSMutableArray array];
    _allLinkDict = [NSMutableDictionary dictionary];
    
    for (LinkRecord *record in links) {
        TYLink *forwardLink = [[TYLink alloc] initWithLinkID:record.linkID isVirtual:record.isVirtual];
        forwardLink.currentNodeID = record.headNode;
        forwardLink.nextNodeID = record.endNode;
        forwardLink.length = record.length;
        forwardLink.line = record.line;
        NSString *forwardLinkKey = [NSString stringWithFormat:@"%d%d", forwardLink.currentNodeID, forwardLink.nextNodeID];
        [_allLinkDict setObject:forwardLink forKey:forwardLinkKey];
        
        if (record.isVirtual) {
            [_virtualLinkArray addObject:forwardLink];
        } else {
            [_linkArray addObject:forwardLink];
        }
        
        if (!record.isOneWay) {
            TYLink *reverseLink = [[TYLink alloc] initWithLinkID:record.linkID isVirtual:record.isVirtual];
            reverseLink.currentNodeID = record.endNode;
            reverseLink.nextNodeID = record.headNode;
            reverseLink.length = record.length;
            //            reverseLink.line = record.line;
            reverseLink.line = [self reverseFirstPath:record.line];
            NSString *reverseLinkKey = [NSString stringWithFormat:@"%d%d", reverseLink.currentNodeID, reverseLink.nextNodeID];
            [_allLinkDict setObject:reverseLink forKey:reverseLinkKey];
            
            if (record.isVirtual) {
                [_virtualLinkArray addObject:reverseLink];
            } else {
                [_linkArray addObject:reverseLink];
            }
        }
    }
}

- (AGSPolyline *)reverseFirstPath:(AGSPolyline *)line
{
    AGSMutablePolyline *reverseLine = [[AGSMutablePolyline alloc] init];
    [reverseLine addPathToPolyline];
    for (int i = (int)[line numPointsInPath:0] - 1; i >= 0; --i) {
        [reverseLine addPointToPath:[line pointOnPath:0 atIndex:i]];
    }
    return reverseLine;
}

- (void)processNodesAndLinks
{
    for (TYLink *link in _allLinkDict.allValues) {
        TYNode *headNode = [_allNodeDict objectForKey:@(link.currentNodeID)];
        [headNode addLink:link];
        link.nextNode = [_allNodeDict objectForKey:@(link.nextNodeID)];
    }
}

- (void)computePaths:(TYNode *)source
{
    //    NSDate *now = [NSDate date];
    
    source.minDistance = 0;
    
    NSMutableArray *nodeQueue = [[NSMutableArray alloc] init];
    [nodeQueue addObject:source];
    
    while (nodeQueue.count > 0) {
        [nodeQueue sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            TYNode *node1 = (TYNode *)obj1;
            TYNode *node2 = (TYNode *)obj2;
            
            return node1.minDistance > node2.minDistance;
        }];
        
        TYNode *u = nodeQueue[0];
        [nodeQueue removeObjectAtIndex:0];
        
        for (TYLink *e in u.adjacencies) {
            TYNode *v = e.nextNode;
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
    //    NSDate *endComputation = [NSDate date];
    //    NSLog(@"Computing Time: %f", [endComputation timeIntervalSinceDate:now]);
}

- (AGSPolyline *)getShorestPathTo:(TYNode *)target
{
    NSMutableArray *array = [NSMutableArray array];
    for (TYNode *node = target; node != nil; node = node.previousNode) {
        [array addObject:node];
    }
    NSArray *reverseArray = [[array reverseObjectEnumerator] allObjects];
    
    
    AGSMutablePolyline *resultLine = [[AGSMutablePolyline alloc] init];
    [resultLine addPathToPolyline];
    
    for (TYNode *node in reverseArray) {
        if (node && node.previousNode) {
            NSString *key = [NSString stringWithFormat:@"%d%d", node.previousNode.nodeID, node.nodeID];
            TYLink *link = [_allLinkDict objectForKey:key];
            for (int i = 0; i < [link.line numPointsInPath:0]; ++i) {
                [resultLine addPointToPath:[link.line pointOnPath:0 atIndex:i]];
            }
        }
    }
    AGSPolyline *result = (AGSPolyline *)[[AGSGeometryEngine defaultGeometryEngine] simplifyGeometry:resultLine];
//    NSLog(@"%d point in Path", (int)result.numPoints);
    return result;
}

- (void)reset
{
    for (TYNode *node in _nodeArray) {
        [node reset];
    }
    
    for (TYNode *node in _virtualNodeArray) {
        [node reset];
    }
}

- (TYNode *)processTempNodeForStart:(AGSPoint *)startPoint
{
    [tempStartLinkArray removeAllObjects];
    [tempStartNodeArray removeAllObjects];
    
    [replacedStartLinkArray removeAllObjects];
    //    [replacedStartNodeArray removeAllObjects];
    
    AGSProximityResult *result = [engine nearestCoordinateInGeometry:_unionLine toPoint:startPoint];
    AGSPoint *np = result.point;
    for (TYNode *node in _nodeArray) {
        if ([engine geometry:np withinGeometry:node.pos]) {
            NSLog(@"Point Equal to One of the Nodes!");
            return node;
        }
    }
    
    // Add New Temp Nodes
    TYNode *newTempNode = [[TYNode alloc] initWithNodeID:tempNodeID isVirtual:NO];
    tempNodeID++;
    newTempNode.pos = np;
    [tempStartNodeArray addObject:newTempNode];
    
    // Add New Temp Links
    for (TYLink *link in _linkArray) {
        result = [engine nearestCoordinateInGeometry:link.line toPoint:np];
        int index = (int)result.pointIndex;
        
        if ([engine geometry:link.line containsGeometry:np]) {
            AGSMutablePolyline *firstPartPolyline = [[AGSMutablePolyline alloc] init];
            [firstPartPolyline addPathToPolyline];
            AGSMutablePolyline *secondPartPolyline = [[AGSMutablePolyline alloc] init];
            [secondPartPolyline addPathToPolyline];
            
            for (int i = 0; i < [link.line numPointsInPath:0]; ++i) {
                AGSPoint *p = [link.line pointOnPath:0 atIndex:i];
                if (i <= index) {
                    [firstPartPolyline addPointToPath:p];
                } else {
                    [secondPartPolyline addPointToPath:p];
                }
            }
            [firstPartPolyline addPointToPath:np];
            [secondPartPolyline insertPoint:np onPath:0 atIndex:0];
            
            TYLink *firstPartLink = [[TYLink alloc] initWithLinkID:tempLinkID isVirtual:NO];
            firstPartLink.currentNodeID = link.currentNodeID;
            firstPartLink.nextNodeID = newTempNode.nodeID;
            firstPartLink.length = [engine lengthOfGeometry:firstPartPolyline];
            firstPartLink.line = firstPartPolyline;
            
            TYLink *secondPartLink = [[TYLink alloc] initWithLinkID:tempLinkID isVirtual:NO];
            secondPartLink.currentNodeID = newTempNode.nodeID;
            secondPartLink.nextNodeID = link.nextNodeID;
            secondPartLink.length = [engine lengthOfGeometry:secondPartPolyline];
            secondPartLink.line = secondPartPolyline;
            tempLinkID++;
            
            [tempStartLinkArray addObject:firstPartLink];
            [tempStartLinkArray addObject:secondPartLink];
            [replacedStartLinkArray addObject:link];
        }
    }
    
    for (TYNode *newNode in tempStartNodeArray) {
        [_allNodeDict setObject:newNode forKey:@(newTempNode.nodeID)];
    }
    
    for (TYLink *newLink in tempStartLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(newLink.currentNodeID)];
        [headNode addLink:newLink];
        newLink.nextNode = [_allNodeDict objectForKey:@(newLink.nextNodeID)];
        
        NSString *newLinkKey = [NSString stringWithFormat:@"%d%d", newLink.currentNodeID, newLink.nextNodeID];
        [_allLinkDict setObject:newLink forKey:newLinkKey];
        
        [_linkArray addObject:newLink];
    }
    
    for (TYLink *replacedLink in replacedStartLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(replacedLink.currentNodeID)];
        [headNode removeLink:replacedLink];
        
        NSString *replacedLinkKey = [NSString stringWithFormat:@"%d%d", replacedLink.currentNodeID, replacedLink.nextNodeID];
        [_allLinkDict removeObjectForKey:replacedLinkKey];
        [_linkArray removeObject:replacedLink];
        
    }
    
    return newTempNode;
}


- (TYNode *)processTempNodeForEnd:(AGSPoint *)endPoint
{
    [tempEndLinkArray removeAllObjects];
    [tempEndNodeArray removeAllObjects];
    [replacedEndLinkArray removeAllObjects];
    
    AGSProximityResult *result = [engine nearestCoordinateInGeometry:_unionLine toPoint:endPoint];
    AGSPoint *np = result.point;
    for (TYNode *node in _nodeArray) {
        if ([engine geometry:np withinGeometry:node.pos]) {
//            NSLog(@"Point Equal to One of the Nodes!");
            return node;
        }
    }
    
    // Add New Temp Nodes
    TYNode *newTempNode = [[TYNode alloc] initWithNodeID:tempNodeID isVirtual:NO];
    tempNodeID++;
    newTempNode.pos = np;
    [tempEndNodeArray addObject:newTempNode];
    
    // Add New Temp Links
    for (TYLink *link in _linkArray) {
        result = [engine nearestCoordinateInGeometry:link.line toPoint:np];
        int index = (int)result.pointIndex;
        
        if ([engine geometry:link.line containsGeometry:np]) {
            AGSMutablePolyline *firstPartPolyline = [[AGSMutablePolyline alloc] init];
            [firstPartPolyline addPathToPolyline];
            AGSMutablePolyline *secondPartPolyline = [[AGSMutablePolyline alloc] init];
            [secondPartPolyline addPathToPolyline];
            
            for (int i = 0; i < [link.line numPointsInPath:0]; ++i) {
                AGSPoint *p = [link.line pointOnPath:0 atIndex:i];
                if (i <= index) {
                    [firstPartPolyline addPointToPath:p];
                } else {
                    [secondPartPolyline addPointToPath:p];
                }
            }
            [firstPartPolyline addPointToPath:np];
            [secondPartPolyline insertPoint:np onPath:0 atIndex:0];
            
            TYLink *firstPartLink = [[TYLink alloc] initWithLinkID:tempLinkID isVirtual:NO];
            firstPartLink.currentNodeID = link.currentNodeID;
            firstPartLink.nextNodeID = newTempNode.nodeID;
            firstPartLink.length = [engine lengthOfGeometry:firstPartPolyline];
            firstPartLink.line = firstPartPolyline;
            
            TYLink *secondPartLink = [[TYLink alloc] initWithLinkID:tempLinkID isVirtual:NO];
            secondPartLink.currentNodeID = newTempNode.nodeID;
            secondPartLink.nextNodeID = link.nextNodeID;
            secondPartLink.length = [engine lengthOfGeometry:secondPartPolyline];
            secondPartLink.line = secondPartPolyline;
            tempLinkID++;
            
            [tempEndLinkArray addObject:firstPartLink];
            [tempEndLinkArray addObject:secondPartLink];
            [replacedEndLinkArray addObject:link];
        }
    }
    
    for (TYNode *newNode in tempEndNodeArray) {
        [_allNodeDict setObject:newNode forKey:@(newTempNode.nodeID)];
    }
    
    for (TYLink *newLink in tempEndLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(newLink.currentNodeID)];
        [headNode addLink:newLink];
        newLink.nextNode = [_allNodeDict objectForKey:@(newLink.nextNodeID)];
        
        NSString *newLinkKey = [NSString stringWithFormat:@"%d%d", newLink.currentNodeID, newLink.nextNodeID];
        [_allLinkDict setObject:newLink forKey:newLinkKey];
        
        [_linkArray addObject:newLink];
    }
    
    for (TYLink *replacedLink in replacedEndLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(replacedLink.currentNodeID)];
        [headNode removeLink:replacedLink];
        
        NSString *replacedLinkKey = [NSString stringWithFormat:@"%d%d", replacedLink.currentNodeID, replacedLink.nextNodeID];
        [_allLinkDict removeObjectForKey:replacedLinkKey];
        [_linkArray removeObject:replacedLink];
    }
    
    return newTempNode;
}

- (void)resetTempNodeForStart
{
    for (TYLink *replacedLink in replacedStartLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(replacedLink.currentNodeID)];
        [headNode addLink:replacedLink];
        
        NSString *replacedLinkKey = [NSString stringWithFormat:@"%d%d", replacedLink.currentNodeID, replacedLink.nextNodeID];
        [_allLinkDict setObject:replacedLink forKey:replacedLinkKey];
        [_linkArray addObject:replacedLink];
    }
    
    for (TYLink *newLink in tempStartLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(newLink.currentNodeID)];
        [headNode removeLink:newLink];
        newLink.nextNode = nil;
        
        NSString *newLinkKey = [NSString stringWithFormat:@"%d%d", newLink.currentNodeID, newLink.nextNodeID];
        [_allLinkDict removeObjectForKey:newLinkKey];
        [_linkArray removeObject:newLink];
    }
    
    for (TYNode *newNode in tempStartNodeArray) {
        [_allNodeDict removeObjectForKey:@(newNode.nodeID)];
    }
    
    [replacedStartLinkArray removeAllObjects];
    [tempStartLinkArray removeAllObjects];
    [tempStartNodeArray removeAllObjects];
}

- (void)resetTempNodeForEnd
{
    for (TYLink *replacedLink in replacedEndLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(replacedLink.currentNodeID)];
        [headNode addLink:replacedLink];
        
        NSString *replacedLinkKey = [NSString stringWithFormat:@"%d%d", replacedLink.currentNodeID, replacedLink.nextNodeID];
        [_allLinkDict setObject:replacedLink forKey:replacedLinkKey];
        [_linkArray addObject:replacedLink];
    }
    
    for (TYLink *newLink in tempEndLinkArray) {
        TYNode *headNode = [_allNodeDict objectForKey:@(newLink.currentNodeID)];
        [headNode removeLink:newLink];
        newLink.nextNode = nil;
        
        NSString *newLinkKey = [NSString stringWithFormat:@"%d%d", newLink.currentNodeID, newLink.nextNodeID];
        [_allLinkDict removeObjectForKey:newLinkKey];
        [_linkArray removeObject:newLink];
    }
    
    for (TYNode *newNode in tempEndNodeArray) {
        [_allNodeDict removeObjectForKey:@(newNode.nodeID)];
    }
    
    [replacedEndLinkArray removeAllObjects];
    [tempEndLinkArray removeAllObjects];
    [tempEndNodeArray removeAllObjects];
}

- (TYNode *)getTempNode:(AGSPoint *)point
{
    AGSProximityResult *result = [engine nearestCoordinateInGeometry:_unionLine toPoint:point];
    AGSPoint *np = result.point;
    for (TYNode *node in _nodeArray) {
        if ([engine geometry:np withinGeometry:node.pos]) {
            //            NSLog(@"Existing Node");
            return node;
        }
    }
    
    TYNode *newTempNode = [[TYNode alloc] initWithNodeID:tempNodeID++ isVirtual:NO];
    newTempNode.pos = np;
    //    NSLog(@"New Temp Node");
    return newTempNode;
}

- (NSArray *)getTempLinks:(AGSPoint *)point
{
    AGSProximityResult *result = [engine nearestCoordinateInGeometry:_unionLine toPoint:point];
    AGSPoint *np = result.point;
    
    for (TYNode *node in _nodeArray) {
        if ([engine geometry:np withinGeometry:node.pos]) {
            NSLog(@"Existing Links: %d", (int)node.adjacencies.count);
            return node.adjacencies;
        }
    }
    
    NSMutableArray *tempLinkArray = [NSMutableArray array];
    for (TYLink *link in _linkArray) {
        result = [engine nearestCoordinateInGeometry:link.line toPoint:np];
        int index = (int)result.pointIndex;
        
        if ([engine geometry:link.line containsGeometry:np]) {
            AGSMutablePolyline *firstPartPolyline = [[AGSMutablePolyline alloc] init];
            [firstPartPolyline addPathToPolyline];
            AGSMutablePolyline *secondPartPolyline = [[AGSMutablePolyline alloc] init];
            [secondPartPolyline addPathToPolyline];
            
            for (int i = 0; i < [link.line numPointsInPath:0]; ++i) {
                AGSPoint *p = [link.line pointOnPath:0 atIndex:i];
                if (i <= index) {
                    [firstPartPolyline addPointToPath:p];
                } else {
                    [secondPartPolyline addPointToPath:p];
                }
            }
            
            [firstPartPolyline addPointToPath:np];
            [secondPartPolyline insertPoint:np onPath:0 atIndex:0];
            
            TYLink *firstPartLink = [[TYLink alloc] initWithLinkID:tempLinkID isVirtual:NO];
            TYLink *secondPartLink = [[TYLink alloc] initWithLinkID:tempLinkID isVirtual:NO];
            
            firstPartLink.line = firstPartPolyline;
            secondPartLink.line = secondPartPolyline;
            
            tempLinkID++;
            
            [tempLinkArray addObject:firstPartLink];
            [tempLinkArray addObject:secondPartLink];
            
        }
    }
//    NSLog(@"New Temp Links: %d", (int)tempLinkArray.count);
    return tempLinkArray;
}

- (AGSPolyline *)getShorestPathFrom:(AGSPoint *)start To:(AGSPoint *)end
{
    [self reset];
    
    TYNode *startNode = [self processTempNodeForStart:start];
    TYNode *endNode = [self processTempNodeForEnd:end];
    
    [self computePaths:startNode];
    AGSPolyline *nodePath = [self getShorestPathTo:endNode];
    
    [self resetTempNodeForEnd];
    [self resetTempNodeForStart];
    
    if (nodePath.numPoints == 0) {
        return nil;
    }
    
    AGSMutablePolyline *path = [[AGSMutablePolyline alloc] init];
    [path addPathToPolyline];
    
    for (int i = 0; i < [nodePath numPointsInPath:0]; ++i) {
        [path addPointToPath:[nodePath pointOnPath:0 atIndex:i]];
    }
    
    if ([engine distanceFromGeometry:start toGeometry:startNode.pos] > 0) {
        [path insertPoint:start onPath:0 atIndex:0];
//        NSLog(@"Insert Start");
    }
    
    if ([engine distanceFromGeometry:end toGeometry:endNode.pos] > 0) {
        [path addPointToPath:end];
//        NSLog(@"Add End");
    }
    
    return path;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d Links and %d Nodes", (int)(_linkArray.count + _virtualLinkArray.count), (int)(_nodeArray.count + _virtualNodeArray.count)];
}

//#pragma mark Debug Method
//
//- (NSArray *)getShorestNodeArrayTo:(TYNode *)target
//{
//    NSMutableArray *array = [NSMutableArray array];
//    for (TYNode *node = target; node != nil; node = node.previousNode) {
//        [array addObject:node];
//    }
//    NSArray *reverseArray = [[array reverseObjectEnumerator] allObjects];
//    return reverseArray;
//}
//
//- (NSArray *)getShorestNodeArrayFrom:(AGSPoint *)start To:(AGSPoint *)end
//{
//    [self reset];
//    
//    TYNode *startNode = [self processTempNodeForStart:start];
//    TYNode *endNode = [self processTempNodeForEnd:end];
//    
//    [self computePaths:startNode];
//    NSArray *nodeArray = [self getShorestNodeArrayTo:endNode];
//    
//    [self resetTempNodeForEnd];
//    [self resetTempNodeForStart];
//    
//    return nodeArray;
//}

@end