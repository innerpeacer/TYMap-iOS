//
//  TYLink.m
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYLink.h"

@implementation TYLink

- (id)initWithLinkID:(int)linkID isVirtual:(BOOL)isVir;
{
    self = [super init];
    if (self) {
        _linkID = linkID;
        _isVirtual = isVir;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Current: %d, Next: %d, Length: %f", _currentNodeID, _nextNodeID, _length];
}

@end