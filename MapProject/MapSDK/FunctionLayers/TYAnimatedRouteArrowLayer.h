//
//  TYAnimatedRouteArrowLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/5/25.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#import "TYPictureMarkerSymbol.h"
#import "TYSpatialReference.h"

@interface TYAnimatedRouteArrowLayer : AGSGraphicsLayer

+ (TYAnimatedRouteArrowLayer *)animatedRouteArrowLayerWithSpatialReference:(TYSpatialReference *)sr;

- (void)showRouteArrow:(NSArray *)array;

- (void)stopShowingArrow;

@end
