//
//  TYLabelLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"

@class TYLabelGroupLayer;

@interface TYTextLabelLayer : AGSGraphicsLayer

@property (nonatomic, weak) TYLabelGroupLayer *groupLayer;

@property (nonatomic, strong) NSDictionary *brandDict;

+ (TYTextLabelLayer *)textLabelLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)loadContentsWithInfo:(TYMapInfo *)info;

- (void)displayLabels:(NSMutableArray *)array;

- (BOOL)updateRoomLabel:(NSString *)pid WithName:(NSString *)name;

- (AGSFeatureSet *)getFeatureSet;

@end

