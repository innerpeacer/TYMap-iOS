//
//  TYLabelGroupLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPLabelGroupLayer.h"

@interface IPLabelGroupLayer()
{
    NSMutableArray *visiableBorders;
}

@end

@implementation IPLabelGroupLayer

+ (IPLabelGroupLayer *)labelGroupLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[IPLabelGroupLayer alloc] initWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super init];
    if (self) {
        visiableBorders = [[NSMutableArray alloc] init];
        
        _labelLayer = [IPTextLabelLayer textLabelLayerWithSpatialReference:sr];
        _labelLayer.allowHitTest = NO;
        _labelLayer.groupLayer = self;
        
        _facilityLayer = [IPFacilityLayer facilityLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
        _facilityLayer.selectionColor = [UIColor cyanColor];
        _facilityLayer.groupLayer = self;
    }
    return self;
}

- (void)setRenderingScheme:(TYRenderingScheme *)rs
{
    [_facilityLayer setRenderingScheme:rs];
}

- (void)loadContents:(NSDictionary *)mapData
{
    [_labelLayer removeAllGraphics];
    [_facilityLayer removeAllGraphics];
    
    [_labelLayer loadContents:mapData[@"label"]];
    [_facilityLayer loadContents:mapData[@"facility"]];
}

//- (void)loadContentsWithInfo:(TYMapInfo *)info
//{
//    [_labelLayer removeAllGraphics];
//    [_facilityLayer removeAllGraphics];
//
//    [_labelLayer loadContentsWithInfo:info];
//    [_facilityLayer loadContentsWithInfo:info];
//}

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

- (TYPoi *)getFacilityPoiWithPoiID:(NSString *)pid
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
    [_labelLayer displayLabels:visiableBorders];
}

- (BOOL)updateRoomLabel:(NSString *)pid WithName:(NSString *)name
{
    return [_labelLayer updateRoomLabel:pid WithName:name];
}

- (AGSFeatureSet *)getTextFeatureSet
{
    return [_labelLayer getFeatureSet];
}

@end
