//
//  MRSuperLink.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRSuperLink.h"

@implementation MRSuperLink

- (id)initWithLinkID:(int)linkID;
{
    self = [super init];
    if (self) {
        _linkID = linkID;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Current: %d, Next: %d, Length: %f", _currentNodeID, _nextNodeID, _length];
}


@end
