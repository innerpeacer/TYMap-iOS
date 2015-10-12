//
//  TYBuildingLink.m
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYBuildingLink.h"

@implementation TYBuildingLink

- (id)initWithLinkID:(int)linkID isVirtual:(BOOL)isVir isOneWay:(BOOL)isOW
{
    self = [super init];
    if (self) {
        _linkID = linkID;
        _isVirtual = isVir;
        _isOneWay = isOW;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Head: %d, End: %d, Length: %f", _headNodeID, _endNodeID, _length];
}

@end
