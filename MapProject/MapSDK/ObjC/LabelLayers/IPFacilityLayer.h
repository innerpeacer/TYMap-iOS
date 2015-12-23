//
//  TYFacilityLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYRenderingScheme.h"
#import "TYPoi.h"


@class IPLabelGroupLayer;

@interface IPFacilityLayer : AGSGraphicsLayer

@property (nonatomic, weak) IPLabelGroupLayer *groupLayer;

+ (IPFacilityLayer *)facilityLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;
+ (IPFacilityLayer *)facilityLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)loadContents:(AGSFeatureSet *)set;

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor;

- (void)showFacilityWithCategory:(int)categoryID;

- (void)showAllFacilities;

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs;

- (TYPoi *)getPoiWithPoiID:(NSString *)pid;

- (void)highlightPoi:(NSString *)poiID;

- (void)updateLabels:(NSMutableArray *)array;

- (void)setRenderingScheme:(TYRenderingScheme *)rs;

@end
