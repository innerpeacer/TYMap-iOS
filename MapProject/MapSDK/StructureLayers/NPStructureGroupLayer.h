//
//  TYStructureGroupLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "NPFloorLayer.h"
#import "NPRoomLayer.h"
#import "TYAssetLayer.h"

@interface NPStructureGroupLayer : NSObject

@property (nonatomic, strong) NPFloorLayer *floorLayer;
@property (nonatomic, strong) NPRoomLayer *roomLayer;
@property (nonatomic, strong) TYAssetLayer *asserLayer;

+ (NPStructureGroupLayer *)structureLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(TYMapInfo *)info;

- (NPPoi *)getRoomPoiWithPoiID:(NSString *)pid;
- (void)highlightRoomPoi:(NSString *)poiID;
- (NPPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y;

- (void)clearSelection;

- (void)setRoomSelected:(BOOL)selected forGraphic:(AGSGraphic *)graphic;


- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getRoomFeatureSet;

@end
