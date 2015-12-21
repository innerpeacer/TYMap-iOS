//
//  TYFloorLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYRenderingScheme.h"

@interface IPFloorLayer : AGSGraphicsLayer

+ (IPFloorLayer *)floorLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

- (void)loadContents:(AGSFeatureSet *)set;

- (void)setRenderingScheme:(TYRenderingScheme *)rs;

@end
