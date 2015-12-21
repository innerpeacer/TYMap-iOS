//
//  TYAnimatedRouteArrowLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/5/25.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface IPAnimatedRouteArrowLayer : AGSGraphicsLayer

+ (IPAnimatedRouteArrowLayer *)animatedRouteArrowLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)showRouteArrow:(NSArray *)array;

- (void)stopShowingArrow;

@end
