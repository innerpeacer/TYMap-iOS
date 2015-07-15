//
//  TYLabelGroupLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYTextLabelLayer.h"
#import "TYFacilityLayer.h"

@class TYMapView;

@interface TYLabelGroupLayer : NSObject

@property (nonatomic, weak) TYMapView *mapView;

@property (nonatomic, strong) TYTextLabelLayer *labelLayer;
@property (nonatomic, strong) TYFacilityLayer *facilityLayer;

+ (TYLabelGroupLayer *)labelGroupLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(TYMapInfo *)info;

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
