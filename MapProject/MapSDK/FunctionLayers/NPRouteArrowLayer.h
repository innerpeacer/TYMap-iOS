//
//  NPRouteArrowLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#import "TYSpatialReference.h"
#import "TYPictureMarkerSymbol.h"

@interface NPRouteArrowLayer : AGSGraphicsLayer

+ (NPRouteArrowLayer *)routeArrowLayerWithSpatialReference:(TYSpatialReference *)sr;

- (void)showRouteArrow:(NSArray *)array;

@end
