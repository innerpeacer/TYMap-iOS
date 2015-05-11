//
//  NPRouteArrowLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#import "NPSpatialReference.h"
#import "NPPictureMarkerSymbol.h"

@interface NPRouteArrowLayer : AGSGraphicsLayer

+ (NPRouteArrowLayer *)routeArrowLayerWithSpatialReference:(NPSpatialReference *)sr;


- (void)showRouteArrow:(NSArray *)array;
//- (void)showRouteArrow:(AGSPolyline *)line;

@end
