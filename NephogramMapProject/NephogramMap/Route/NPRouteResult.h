//
//  NPRouteResult.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPRoutePart.h"
#import "NPDirectionalHint.h"

@interface NPRouteResult : NSObject


@property (nonatomic, readonly) NSArray *allRoutePartsArray;
@property (nonatomic, readonly) NSDictionary *allFloorRoutePartDict;

+ (NPRouteResult *)routeResultWithRouteParts:(NSArray *)routePartArray;

- (BOOL)isDeviatingFromRoute:(NPLocalPoint *)point WithThrehold:(double)distance;

- (NPRoutePart *)getNearestRoutePart:(NPLocalPoint *)location;

- (NSArray *)getRoutePartsOnFloor:(int)floor;

- (NPRoutePart *)getRoutePart:(int)index;

- (NSArray *)getRouteDirectionalHint:(NPRoutePart *)rp;
- (NPDirectionalHint *)getDirectionHintForLocation:(NPLocalPoint *)location FromHints:(NSArray *)directions;

+ (AGSPolyline *)getSubPolyline:(AGSPolyline *)originalLine WithStart:(AGSPoint *)start End:(AGSPoint *)end;
@end