//
//  NPLabelGroupLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"
#import "NPLabelLayer.h"
#import "NPFacilityLayer.h"

@interface NPLabelGroupLayer : NSObject



@property (nonatomic, strong) NPLabelLayer *labelLayer;
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

@end
