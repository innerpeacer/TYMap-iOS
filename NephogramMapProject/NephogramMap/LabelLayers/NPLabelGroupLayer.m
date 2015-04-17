//
//  NPLabelGroupLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPLabelGroupLayer.h"

@interface NPLabelGroupLayer()
{
    NSMutableArray *visiableBorders;
}

@end

@implementation NPLabelGroupLayer

+ (NPLabelGroupLayer *)labelGroupLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[NPLabelGroupLayer alloc] initWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super init];
    if (self) {
        visiableBorders = [[NSMutableArray alloc] init];
        
        _labelLayer = [NPTextLabelLayer textLabelLayerWithSpatialReference:sr];
        _labelLayer.allowHitTest = NO;
        _labelLayer.groupLayer = self;
        
        _facilityLayer = [NPFacilityLayer facilityLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
        _facilityLayer.selectionColor = [UIColor cyanColor];
        _facilityLayer.groupLayer = self;
    }
    return self;
}

- (void)loadContentsWithInfo:(NPMapInfo *)info
{
    [_labelLayer removeAllGraphics];
    [_facilityLayer removeAllGraphics];

    [_labelLayer loadContentsWithInfo:info];
    [_facilityLayer loadContentsWithInfo:info];
}

- (void)clearSelection
{
    [_facilityLayer clearSelection];
    [_facilityLayer showAllFacilities];
}

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor
{
    return [_facilityLayer getAllFacilityCategoryIDOnCurrentFloor];
}

- (void)showFacilityWithCategory:(int)categoryID
{
    [_facilityLayer showFacilityWithCategory:categoryID];
}

- (void)showAllFacilities
{
    [_facilityLayer showAllFacilities];
}

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs
{
    [_facilityLayer showFacilityOnCurrentWithCategorys:categoryIDs];
}

- (NPPoi *)getFacilityPoiWithPoiID:(NSString *)pid
{
    return [_facilityLayer getPoiWithPoiID:pid];
}

- (void)highlightFacilityPoi:(NSString *)poiID
{
    [_facilityLayer highlightPoi:poiID];
}

- (void)setFacilitySelected:(BOOL)selected forGraphic:(AGSGraphic *)graphic
{
    [_facilityLayer setSelected:selected forGraphic:graphic];
}

- (void)updateLabels
{
    [visiableBorders removeAllObjects];
    
    [_facilityLayer updateLabels:visiableBorders];
    [_labelLayer updateLabels:visiableBorders];
}

@end
