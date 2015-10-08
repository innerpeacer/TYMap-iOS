//
//  RouteNetworkDataset.m
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "RouteNetworkDataset.h"

@implementation RouteNetworkDataset

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

- (NSArray *)getShorestPathTo:(TYNode *)target
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (TYNode *node = target; node != nil; node = node.previousNode) {
        [array addObject:node];
    }
    
    return [[array reverseObjectEnumerator] allObjects];
}

- (void)reset
{
    for (TYNode *node in _allNodeArray) {
        [node reset];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d Links and %d Nodes", (int)_allLinkArray.count, (int)_allNodeArray.count];
}

@end
