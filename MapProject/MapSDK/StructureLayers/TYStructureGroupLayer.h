//
//  TYStructureGroupLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYFloorLayer.h"
#import "TYRoomLayer.h"
#import "TYAssetLayer.h"

@interface TYStructureGroupLayer : NSObject

@property (nonatomic, strong) TYFloorLayer *floorLayer;
@property (nonatomic, strong) TYRoomLayer *roomLayer;
@property (nonatomic, strong) TYAssetLayer *asserLayer;

+ (TYStructureGroupLayer *)structureLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(TYMapInfo *)info;

- (TYPoi *)getRoomPoiWithPoiID:(NSString *)pid;
- (void)highlightRoomPoi:(NSString *)poiID;
- (TYPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y;

- (void)clearSelection;

- (void)setRoomSelected:(BOOL)selected forGraphic:(AGSGraphic *)graphic;


- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getRoomFeatureSet;

@end
