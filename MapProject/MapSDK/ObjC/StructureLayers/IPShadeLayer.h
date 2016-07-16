//
//  IPShadeLayer.h
//  MapProject
//
//  Created by innerpeacer on 16/7/15.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYRenderingScheme.h"

@interface IPShadeLayer : AGSGraphicsLayer

+ (IPShadeLayer *)shadeLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;
+ (IPShadeLayer *)shadeLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)loadContents:(AGSFeatureSet *)set;

- (void)setRenderingScheme:(TYRenderingScheme *)rs;

@end
