//
//  NPLabelLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"

@class NPLabelGroupLayer;

@interface NPTextLabelLayer : AGSGraphicsLayer

@property (nonatomic, weak) NPLabelGroupLayer *groupLayer;

@property (nonatomic, strong) NSDictionary *brandDict;

+ (NPTextLabelLayer *)textLabelLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(NPMapInfo *)info;

- (void)displayLabels:(NSMutableArray *)array;

- (BOOL)updateRoomLabel:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getFeatureSet;

@end

