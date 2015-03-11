//
//  NPRoomLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"
#import "NPRenderingScheme.h"
#import "NPPoi.h"

@interface NPRoomLayer : AGSGraphicsLayer

+ (NPRoomLayer *)roomLayerWithRenderingScheme:(NPRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(NPMapInfo *)info;
- (NPPoi *)getPoiWithPoiID:(NSString *)pid;

@end
