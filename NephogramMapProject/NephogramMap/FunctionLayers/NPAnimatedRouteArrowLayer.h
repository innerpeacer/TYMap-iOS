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

@property (nonatomic, strong) NSArray *lineToShow;

- (void)showRouteArrow:(NSArray *)array;

//- (void)showRouteArrow:(NSArray *)array withTranslation:(double)translation;

- (void)stopShowArrow;

@end
