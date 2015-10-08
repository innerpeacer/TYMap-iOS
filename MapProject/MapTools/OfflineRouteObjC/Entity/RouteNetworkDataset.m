//
//  RouteNetworkDataset.m
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "RouteNetworkDataset.h"

@implementation RouteNetworkDataset

- (id)initWithNodes:(NSArray *)nodes VirtualNodes:(NSArray *)virtualNods Links:(NSArray *)links VirtualLinks:(NSArray *)virtualLinks
{
    self = [super init];
    if (self) {
        _nodeArray = [NSArray arrayWithArray:nodes];
        _virtualNodeArray = [NSArray arrayWithArray:virtualNods];
        _linkArray = [NSArray arrayWithArray:links];
        _virtualLinkArray = [NSArray arrayWithArray:virtualLinks];
        
        
        NSMutableArray *allLinkLines = [NSMutableArray array];
        for (TYLink *link in _linkArray) {
            [allLinkLines addObject:link.line];
        }
        
        for (TYLink *link in _virtualLinkArray) {
            [allLinkLines addObject:link.line];
        }
        _unionLine = (AGSPolyline *)[[AGSGeometryEngine defaultGeometryEngine] unionGeometries:allLinkLines];
        
    }
    return self;
}

- (AGSPoint *)getNearestPoint:(AGSPoint *)point
{
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    AGSProximityResult *result = [engine nearestCoordinateInGeometry:_unionLine toPoint:point];
    return result.point;
}

- (NSArray *)getNearestNodes:(AGSPoint *)point
{
    NSMutableArray *nodeArray = [NSMutableArray array];
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint *np = [self getNearestPoint:point];

    for (TYNode *node in _nodeArray) {
        if ([engine geometry:node.pos withinGeometry:np]) {
            [nodeArray addObject:node];
            break;
        }
    }
    
    if (nodeArray.count == 0) {
        NSArray *linkArray = [self getNearestLinks:point];
        for (TYLink *link in linkArray) {
            [nodeArray addObject:link.nextNode];
        }
    }
    
//    NSLog(@"NearestNodes: %d", (int)nodeArray.count);
    return nodeArray;
}

- (NSArray *)getNearestLinks:(AGSPoint *)point
{
    NSMutableArray *linkArray = [NSMutableArray array];
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint *np = [self getNearestPoint:point];
    for (TYLink *link in _linkArray) {
        if ([engine geometry:link.line containsGeometry:np]) {
//        if ([engine geometry:np touchesGeometry:link.line]) {
            [linkArray addObject:link];
        }
    }
//    NSLog(@"NearestLinks: %d", (int)linkArray.count);
    return linkArray;
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
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    
    NSMutableArray *array = [NSMutableArray array];
    for (TYNode *node = target; node != nil; node = node.previousNode) {
        [array addObject:node];
    }
    NSArray *reverseArray = [[array reverseObjectEnumerator] allObjects];
    
//    AGSMutablePolyline *resultLine = [[AGSMutablePolyline alloc] init];
//    [resultLine addPathToPolyline];
//
////    AGSPolyline *resultLine = [[AGSPolyline alloc] init];
//    for (TYNode *node in reverseArray) {
//        if (node && node.previousNode) {
//            NSString *key = [NSString stringWithFormat:@"%d%d", node.nodeID, node.previousNode.nodeID];
//            TYLink *link = [_allLinkDict objectForKey:key];
//            for (int i = 0; i < [link.line numPointsInPath:0]; ++i) {
//                [resultLine addPointToPath:[link.line pointOnPath:0 atIndex:i]];
//            }
////            resultLine = (AGSPolyline *)[engine unionGeometries:@[resultLine, link.line]];
//        }
//    }
//    NSLog(@"Primitive Points: %d", (int)resultLine.numPoints);
//    AGSPolyline *result = (AGSPolyline *)[[AGSGeometryEngine defaultGeometryEngine] simplifyGeometry:resultLine];
////    AGSPolyline *result = resultLine;
//
//    NSLog(@"Simplified Points: %d", (int)result.numPoints);

        NSMutableArray *pathArray = [NSMutableArray array];
        for (TYNode *node in reverseArray) {
            if (node && node.previousNode) {
                NSString *key = [NSString stringWithFormat:@"%d%d", node.nodeID, node.previousNode.nodeID];
                TYLink *link = [_allLinkDict objectForKey:key];
                [pathArray addObject:link.line];
            }
        }
    AGSPolyline *result = (AGSPolyline *)[engine unionGeometries:pathArray];
    
    if (result && result.numPoints > 0) {
        return result;
    }
    return nil;
}

- (void)reset
{
//    for (TYNode *node in _allNodeArray) {
//        [node reset];
//    }
    
    for (TYNode *node in _nodeArray) {
        [node reset];
    }
    
    for (TYNode *node in _virtualNodeArray) {
        [node reset];
    }
}

- (AGSPolyline *)getShorestPathFrom:(AGSPoint *)start To:(AGSPoint *)end
{
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    
    NSArray *startNodeArray = [self getNearestNodes:start];
    NSArray *endNodeArray = [self getNearestNodes:end];
    
    NSLog(@"%d startNodes, %d endNodes", (int)startNodeArray.count, (int)endNodeArray.count);
    
    AGSPolyline *result = nil;
    double minLength = 1000000000;
    
    int computationTimes = 0;

    for (TYNode *startNode in startNodeArray) {
        for (TYNode *endNode in endNodeArray) {
            computationTimes++;
            
            [self reset];
            [self computePaths:startNode];
            AGSPolyline *path = [self getShorestPathTo:endNode];
            
            if (path) {
                AGSPoint *firstPoint = [path pointOnPath:0 atIndex:0];
                double headDistance = [engine distanceFromGeometry:firstPoint toGeometry:start];
                double endDistance = [engine distanceFromGeometry:firstPoint toGeometry:end];
                
                if (headDistance > endDistance) {
                    AGSMutablePolyline *reversedPath = [[AGSMutablePolyline alloc] init];
                    [reversedPath addPathToPolyline];
                    for (int i = (int)[path numPointsInPath:0] - 1; i >= 0; --i) {
                        [reversedPath addPointToPath:[path pointOnPath:0 atIndex:i]];
                    }
                    path = reversedPath;
                }
            }

            if(path) {
                AGSMutablePolyline *totalLine = [[AGSMutablePolyline alloc] init];
                [totalLine addPathToPolyline];
                for (int i = 0; i < [path numPointsInPath:0]; ++i) {
                    [totalLine addPointToPath:[path pointOnPath:0 atIndex:i]];
                }
                
                if (![engine geometry:path touchesGeometry:start]) {
                    AGSPoint *nearestStartPoint = [self getNearestPoint:start];
                    [totalLine insertPoint:nearestStartPoint onPath:0 atIndex:0];
                    [totalLine insertPoint:start onPath:0 atIndex:0];
                }
                
                if (![engine geometry:path touchesGeometry:end]) {
                    AGSPoint *nearestEndPoint = [self getNearestPoint:end];
                    [totalLine addPoint:nearestEndPoint toPath:0];
                    [totalLine addPoint:end toPath:0];
                }

                double length = [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:totalLine];
                
                if (length < minLength) {
                    minLength = length;
                    result = totalLine;
                }
            }
        }
    }
    
    NSLog(@"%d computations", computationTimes);
    
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d Links and %d Nodes", (int)(_linkArray.count + _virtualLinkArray.count), (int)(_nodeArray.count + _virtualNodeArray.count)];
}

@end
