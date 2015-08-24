//
//  TYAssetLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"
#import "TYRenderingScheme.h"

@interface TYAssetLayer : AGSGraphicsLayer

+ (TYAssetLayer *)assetLayerWithRenderingScheme:(TYRenderingScheme *)aRenderingScheme SpatialReference:(AGSSpatialReference *)sr;

//- (void)loadContentsWithInfo:(TYMapInfo *)info;
- (void)loadContents:(AGSFeatureSet *)set;

- (void)setRenderingScheme:(TYRenderingScheme *)rs;

@end

