//
//  TYNode.m
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYNode.h"

#define LARGE_DISTANCE 1000000000

@implementation TYNode

- (id)initWithNodeID:(int)nodeID isVirtual:(BOOL)isVir
{
    self = [super init];
    if (self) {
        _nodeID = nodeID;
        _minDistance = LARGE_DISTANCE;
        _adjacencies = [[NSMutableArray alloc] init];
        _isVirtual = isVir;
    }
    return self;
}

- (void)addLink:(TYLink *)link
{
    [_adjacencies addObject:link];
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
