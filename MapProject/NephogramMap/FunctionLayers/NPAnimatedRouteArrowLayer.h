//
//  NPAnimatedRouteArrowLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/25.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#import "NPPictureMarkerSymbol.h"
#import "NPSpatialReference.h"

@interface NPAnimatedRouteArrowLayer : AGSGraphicsLayer

+ (NPAnimatedRouteArrowLayer *)animatedRouteArrowLayerWithSpatialReference:(NPSpatialReference *)sr;

- (void)showRouteArrow:(NSArray *)array;

- (void)stopShowingArrow;

@end
