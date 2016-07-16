//
//  TYLabelLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"

@class IPLabelGroupLayer;

@interface IPTextLabelLayer : AGSGraphicsLayer

@property (nonatomic, weak) IPLabelGroupLayer *groupLayer;
@property (nonatomic, strong) NSDictionary *brandDict;

+ (IPTextLabelLayer *)textLabelLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)setTextColor:(UIColor *)color;
- (void)loadContents:(AGSFeatureSet *)set;
- (void)displayLabels:(NSMutableArray *)array;
- (BOOL)updateRoomLabel:(NSString *)pid WithName:(NSString *)name;
- (AGSFeatureSet *)getFeatureSet;
@end

