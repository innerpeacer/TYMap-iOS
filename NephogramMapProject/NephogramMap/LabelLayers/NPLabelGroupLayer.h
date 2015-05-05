//
//  NPLabelGroupLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"
#import "NPTextLabelLayer.h"
#import "NPFacilityLayer.h"

@class NPMapView;

@interface NPLabelGroupLayer : NSObject

@property (nonatomic, weak) NPMapView *mapView;

@property (nonatomic, strong) NPTextLabelLayer *labelLayer;
@property (nonatomic, strong) NPFacilityLayer *facilityLayer;

+ (NPLabelGroupLayer *)labelGroupLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(NPMapInfo *)info;

- (void)clearSelection;

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor;

- (void)showFacilityWithCategory:(int)categoryID;

- (void)showAllFacilities;

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs;

- (NPPoi *)getFacilityPoiWithPoiID:(NSString *)pid;

- (void)highlightFacilityPoi:(NSString *)poiID;

- (void)setFacilitySelected:(BOOL)selected forGraphic:(AGSGraphic *)graphic;

- (void)updateLabels;

- (BOOL)updateRoomLabel:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getTextFeatureSet;

@end
