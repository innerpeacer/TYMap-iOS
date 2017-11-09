//
//  MRParams.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/8.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRParams.h"
#import "MRSuperNode.h"
#import "MRSuperLink.h"

@interface MRParams()
{
    AGSPoint *start;
    AGSPoint *end;
    NSMutableArray *middlePoints;
    
    NSMutableArray *nodeArray;
    MRSuperNode *startNode;
    MRSuperNode *endNode;
    NSMutableArray *middleNodeArray;
}

@end

@implementation MRParams

@synthesize startPoint = start;
@synthesize endPoint = end;
@synthesize stopPoints = middlePoints;

- (id)init
{
    self = [super init];
    if (self) {
        middlePoints = [NSMutableArray array];
    }
    return self;
}

- (void)addStop:(AGSPoint *)stop
{
    [middlePoints addObject:stop];
}

- (int)stopCount
{
    return (int)[middlePoints count];
}

- (AGSPoint *)getStopPoint:(int)i
{
    return middlePoints[i];
}

- (void)buildNodes
{
    nodeArray = [NSMutableArray array];
    middleNodeArray = [NSMutableArray array];
    
    int nodeIndex = 0;
    
    startNode = [[MRSuperNode alloc] initWithNodeID:nodeIndex++];
    startNode.pos = start;
    NSLog(@"s: %f", startNode.minDistance);
    [nodeArray addObject:startNode];
    
    for (int i = 0; i < middlePoints.count; ++i) {
        MRSuperNode *middleNode = [[MRSuperNode alloc] initWithNodeID:nodeIndex++];
        middleNode.pos = middlePoints[i];
        [nodeArray addObject:middleNode];
        [middleNodeArray addObject:middleNode];
    }
    
    endNode = [[MRSuperNode alloc] initWithNodeID:nodeIndex++];
    endNode.pos = end;
    [nodeArray addObject:endNode];
}

- (NSArray *)getSuperNodes
{
    return nodeArray;
}

- (MRSuperNode *)getStartNode
{
    return startNode;
}

- (MRSuperNode *)getEndNode
{
    return endNode;
}

- (NSArray *)getStopNodes
{
    return middleNodeArray;
}

- (NSDictionary *)getCombinations
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    
    {
        NSMutableArray *startCombinations = [NSMutableArray array];
        for (int i = 0; i < middleNodeArray.count; ++i) {
            [startCombinations addObject:[NSMutableArray arrayWithObjects:startNode, middleNodeArray[i], nil]];
        }
        resultDict[@"start"] = startCombinations;
    }
    
    {
        NSMutableArray *endCombinations = [NSMutableArray array];
        for (int i = 0; i < middleNodeArray.count; ++i) {
            [endCombinations addObject:[NSMutableArray arrayWithObjects:middleNodeArray[i], endNode, nil]];
        }
        resultDict[@"end"] = endCombinations;
    }
    
    {
        NSMutableArray *stopCombinations = [NSMutableArray array];
        for (int i = 0; i < middleNodeArray.count; ++i) {
            for (int j = 0; j < middleNodeArray.count; ++j) {
                if (i == j) continue;
                [stopCombinations addObject:[NSMutableArray arrayWithObjects:middleNodeArray[i], middleNodeArray[j], nil]];
            }
        }
        resultDict[@"stops"] = stopCombinations;
    }
    return resultDict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Start: %@, End: %@, Stops: %d", start, end, (int)middlePoints.count];
}

@end
