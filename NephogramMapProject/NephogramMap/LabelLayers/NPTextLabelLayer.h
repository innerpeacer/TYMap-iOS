//
//  NPLabelLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"
//#import "NPLabelGroupLayer.h"

@class NPLabelGroupLayer;

@interface NPTextLabelLayer : AGSGraphicsLayer

@property (nonatomic, weak) NPLabelGroupLayer *groupLayer;

+ (NPTextLabelLayer *)textLabelLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(NPMapInfo *)info;

- (void)updateLabels;

@end
