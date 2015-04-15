//
//  NPFacilityLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"
#import "NPRenderingScheme.h"
#import "NPPoi.h"


@class NPLabelGroupLayer;

@interface NPFacilityLayer : AGSGraphicsLayer

@property (nonatomic, weak) NPLabelGroupLayer *groupLayer;

+ (NPFacilityLayer *)facilityLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(NPMapInfo *)info;

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor;

- (void)showFacilityWithCategory:(int)categoryID;

- (void)showAllFacilities;

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs;

- (NPPoi *)getPoiWithPoiID:(NSString *)pid;

- (void)highlightPoi:(NSString *)poiID;

- (void)updateLabels;

@end
