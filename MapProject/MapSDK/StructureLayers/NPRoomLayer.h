//
//  TYRoomLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYRenderingScheme.h"
#import "NPPoi.h"

@interface NPRoomLayer : AGSGraphicsLayer

+ (NPRoomLayer *)roomLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(TYMapInfo *)info;
- (NPPoi *)getPoiWithPoiID:(NSString *)pid;
- (void)highlightPoi:(NSString *)poiID;
- (NPPoi *)extractPoiOnCurrentFloorWithX:(double)x Y:(double)y;

- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getFeatureSet;

@end
