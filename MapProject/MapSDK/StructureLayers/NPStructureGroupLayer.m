
//
//  TYStructureGroupLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPStructureGroupLayer.h"

@implementation NPStructureGroupLayer

+ (NPStructureGroupLayer *)structureLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    return [[NPStructureGroupLayer alloc] initWithRenderingScheme:aRenderingScheme SpatialReference:sr];
}

- (id)initWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr
{
    self = [super init];
    if (self) {
        _floorLayer = [NPFloorLayer floorLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
        _floorLayer.allowHitTest = NO;
        
        _roomLayer = [NPRoomLayer roomLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];
        _roomLayer.selectionSymbol = aRenderingScheme.defaultHighlightFillSymbol;
        
        _asserLayer = [TYAssetLayer assetLayerWithRenderingScheme:aRenderingScheme SpatialReference:sr];

    }
    return self;
}

- (void)loadContentsWithInfo:(TYMapInfo *)info
{
    [_floorLayer removeAllGraphics];
    [_roomLayer removeAllGraphics];
    [_asserLayer removeAllGraphics];
    
    [_floorLayer loadContentsWithInfo:info];
    [_roomLayer loadContentsWithInfo:info];
    [_asserLayer loadContentsWithInfo:info];
}

- (NPPoi *)getRoomPoiWithPoiID:(NSString *)pid
{
    return [_roomLayer getPoiWithPoiID:pid];
}

- (void)highlightRoomPoi:(NSString *)poiID
{
    [_roomLayer highlightPoi:poiID];
}

- (NPPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y
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
