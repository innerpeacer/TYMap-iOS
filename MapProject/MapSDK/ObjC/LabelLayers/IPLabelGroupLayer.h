//
//  TYLabelGroupLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "IPTextLabelLayer.h"
#import "IPFacilityLayer.h"

@class TYMapView;

@interface IPLabelGroupLayer : NSObject

@property (nonatomic, weak) TYMapView *mapView;

@property (nonatomic, strong) IPTextLabelLayer *labelLayer;
@property (nonatomic, strong) IPFacilityLayer *facilityLayer;

+ (IPLabelGroupLayer *)labelGroupLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;
+ (IPLabelGroupLayer *)labelGroupLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)loadContents:(NSDictionary *)mapData;

- (void)setRenderingScheme:(TYRenderingScheme *)rs;

- (void)clearSelection;

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor;

- (void)showFacilityWithCategory:(int)categoryID;

- (void)showAllFacilities;

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs;

- (TYPoi *)getFacilityPoiWithPoiID:(NSString *)pid;

- (void)highlightFacilityPoi:(NSString *)poiID;

- (void)setFacilitySelected:(BOOL)selected forGraphic:(AGSGraphic *)graphic;

- (void)updateLabels;

- (BOOL)updateRoomLabel:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getTextFeatureSet;

@end
