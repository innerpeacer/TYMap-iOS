//
//  NPRoutePointConverter.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPLocalPoint.h"
#import "NPMapInfo.h"

@interface NPRoutePointConverter : NSObject

- (id)initWithBaseMapExtent:(MapExtent)extent Offset:(MapSize)offset;

- (AGSPoint *)routePointFromLocalPoint:(NPLocalPoint *)localPoint;
- (NPLocalPoint *)localPointFromRoutePoint:(AGSPoint *)routePoint;

- (BOOL)checkPointValid:(NPLocalPoint *)point;

@end
