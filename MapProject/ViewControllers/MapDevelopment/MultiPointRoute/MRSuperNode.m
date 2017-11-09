//
//  MRSuperNode.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRSuperNode.h"
#define LARGE_DISTANCE 1000000000

@implementation MRSuperNode

- (id)initWithNodeID:(int)nodeID
{
    self = [super init];
    if (self) {
        _nodeID = nodeID;
        _minDistance = LARGE_DISTANCE;
        _adjacencies = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addLink:(MRSuperLink *)link
{
    [_adjacencies addObject:link];
}

- (void)removeLink:(MRSuperLink *)link
{
    [_adjacencies removeObject:link];
}

- (void)reset
{
    _minDistance = LARGE_DISTANCE;
    self.previousNode = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID: %d, minDistance: %f", _nodeID, _minDistance];
}

@end
