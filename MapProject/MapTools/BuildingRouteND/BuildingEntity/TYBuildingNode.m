//
//  TYBuildingNode.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYBuildingNode.h"

@implementation TYBuildingNode

- (id)initWithNodeID:(int)nodeID isVirtual:(BOOL)isVir
{
    self = [super init];
    if (self) {
        _nodeID = nodeID;
        _isVirtual = isVir;
        _adjacencies = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addLink:(TYBuildingLink *)link
{
    [_adjacencies addObject:link];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID: %d, Virtual: %d", _nodeID, _isVirtual];
}
@end
