//
//  TYFacilityLabel.m
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYFacilityLabel.h"

@interface TYFacilityLabel()
{
    BOOL isHighlighted;
}
@end

@implementation TYFacilityLabel

#define FACILITY_SIZE 26

CGSize facilitySize = { FACILITY_SIZE, FACILITY_SIZE };

- (id)initWithCategoryID:(int)categoryID Position:(TYPoint *)pos
{
    self = [super init];
    if (self) {
        isHighlighted = NO;
        _position = pos;
        _categoryID = categoryID;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    isHighlighted = highlighted;
    if (isHighlighted) {
        _currentSymbol = _highlightedFacilitySymbol;
    } else {
        _currentSymbol = _normalFacilitySymbol;
    }
}

- (BOOL)isHighlighted
{
    return isHighlighted;
}

- (CGSize)getFacilityLabelSize
{
    return facilitySize;
}

@end