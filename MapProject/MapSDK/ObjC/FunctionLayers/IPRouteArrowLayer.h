//
//  TYRouteArrowLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface IPRouteArrowLayer : AGSGraphicsLayer

+ (IPRouteArrowLayer *)routeArrowLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)showRouteArrow:(NSArray *)array;

@end
