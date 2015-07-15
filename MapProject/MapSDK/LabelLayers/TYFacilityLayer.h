//
//  TYFacilityLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"
#import "NPRenderingScheme.h"
#import "NPPoi.h"


@class TYLabelGroupLayer;

@interface TYFacilityLayer : AGSGraphicsLayer

@property (nonatomic, weak) TYLabelGroupLayer *groupLayer;

+ (TYFacilityLayer *)facilityLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(NPMapInfo *)info;

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor;

- (void)showFacilityWithCategory:(int)categoryID;

- (void)showAllFacilities;

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs;

- (NPPoi *)getPoiWithPoiID:(NSString *)pid;

- (void)highlightPoi:(NSString *)poiID;

- (void)updateLabels:(NSMutableArray *)array;

@end
