
//
//  TYStructureGroupLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "IPStructureGroupLayer.h"

@implementation IPStructureGroupLayer

+ (IPStructureGroupLayer *)structureLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[IPStructureGroupLayer alloc] initWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

+ (IPStructureGroupLayer *)structureLayerWithSpatialReference:(AGSSpatialReference *)sr
{
    return [[IPStructureGroupLayer alloc] initWithSpatialReference:sr];
}

- (id)initWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super init];
    if (self) {
        _floorLayer = [IPFloorLayer floorLayerWithSpatialReference:sr];
        _floorLayer.allowHitTest = NO;

        _roomLayer = [IPRoomLayer roomLayerWithSpatialReference:sr];
        _assetLayer = [IPAssetLayer assetLayerWithSpatialReference:sr];
    }
    return self;
}

- (id)initWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super init];
    if (self) {
        _floorLayer = [IPFloorLayer floorLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
        _floorLayer.allowHitTest = NO;
        
        _roomLayer = [IPRoomLayer roomLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
        _roomLayer.selectionSymbol = aRenderingScheme.defaultHighlightFillSymbol;
        
        _assetLayer = [IPAssetLayer assetLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];

    }
    return self;
}

- (void)setRenderingScheme:(TYRenderingScheme *)rs
{
    [_floorLayer setRenderingScheme:rs];
    [_roomLayer setRenderingScheme:rs];
    _roomLayer.selectionSymbol = rs.defaultHighlightFillSymbol;
    [_assetLayer setRenderingScheme:rs];
}

- (void)loadContents:(NSDictionary *)mapData
{
    [_floorLayer removeAllGraphics];
    [_roomLayer removeAllGraphics];
    [_assetLayer removeAllGraphics];
    
    [_floorLayer loadContents:mapData[@"floor"]];
    [_roomLayer loadContents:mapData[@"room"]];
    [_assetLayer loadContents:mapData[@"asset"]];
}

- (TYPoi *)getRoomPoiWithPoiID:(NSString *)pid
{
    return [_roomLayer getPoiWithPoiID:pid];
}

- (void)highlightRoomPoi:(NSString *)poiID
{
    [_roomLayer highlightPoi:poiID];
}

- (TYPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y
{
    return [_roomLayer extractPoiOnCurrentFloorWithX:x Y:y];
}

- (void)clearSelection
{
    [_roomLayer clearSelection];
//    [assetLayer clearSelection];
}

- (void)setRoomSelected:(BOOL)selected forGraphic:(AGSGraphic *)graphic
{
    [_roomLayer setSelected:selected forGraphic:graphic];
}

- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name
{
    return [_roomLayer updateRoomPOI:pid WithName:name];
}

- (AGSFeatureSet *)getRoomFeatureSet
{
    return [_roomLayer getFeatureSet];
}

@end
