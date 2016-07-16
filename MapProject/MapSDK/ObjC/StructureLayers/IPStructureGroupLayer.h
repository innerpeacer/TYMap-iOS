//
//  TYStructureGroupLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "IPFloorLayer.h"
#import "IPShadeLayer.h"
#import "IPRoomLayer.h"
#import "IPAssetLayer.h"

@interface IPStructureGroupLayer : NSObject

@property (nonatomic, strong) IPFloorLayer *floorLayer;
@property (nonatomic, strong) IPShadeLayer *shadeLayer;
@property (nonatomic, strong) IPRoomLayer *roomLayer;
@property (nonatomic, strong) IPAssetLayer *assetLayer;

+ (IPStructureGroupLayer *)structureLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;
+ (IPStructureGroupLayer *)structureLayerWithSpatialReference:(AGSSpatialReference *)sr;
- (void)setRenderingScheme:(TYRenderingScheme *)rs;

- (void)loadContents:(NSDictionary *)mapData;

- (TYPoi *)getRoomPoiWithPoiID:(NSString *)pid;
- (void)highlightRoomPoi:(NSString *)poiID;
- (TYPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y;

- (void)clearSelection;

- (void)setRoomSelected:(BOOL)selected forGraphic:(AGSGraphic *)graphic;

- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getRoomFeatureSet;

@end
