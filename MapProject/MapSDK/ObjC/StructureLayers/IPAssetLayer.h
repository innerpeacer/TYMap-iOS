//
//  IPAssetLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYRenderingScheme.h"

@interface IPAssetLayer : AGSGraphicsLayer

+ (IPAssetLayer *)assetLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;
+ (IPAssetLayer *)assetLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)loadContents:(AGSFeatureSet *)set;
- (void)setRenderingScheme:(TYRenderingScheme *)rs;

@end

