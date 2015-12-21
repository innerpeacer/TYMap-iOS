//
//  TYRouteHintLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface IPRouteHintLayer : AGSGraphicsLayer

+ (IPRouteHintLayer *)routeHintLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (void)showRouteHint:(AGSPolyline *)line;

@end
