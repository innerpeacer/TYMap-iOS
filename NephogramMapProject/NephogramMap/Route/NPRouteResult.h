//
//  NPRouteResult.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPMapInfo.h"
#import "NPPolyline.h"
#import "NPPoint.h"
#import "NPDirectionalHint.h"
//#import "NPRoutePart.h"

#import <NephogramData/NephogramData.h>

@interface NPRouteResult : NSObject


@property (nonatomic, readonly) NSDictionary *routeGraphicDict;
@property (nonatomic, readonly) NSArray *routeFloorArray;

+ (NPRouteResult *)routeResultWithDict:(NSDictionary *)dict FloorArray:(NSArray *)array;

- (NPPolyline *)getRouteOnFloor:(int)floorIndex;
- (NPPoint *)getFirstPointOnFloor:(int)floorIndex;
- (NPPoint *)getLastPointOnFloor:(int)floorIndex;
- (BOOL)isFirstFloor:(int)floorIndex;
- (BOOL)isLastFloor:(int)floorIndex;
- (NSNumber *)getPreviousFloor:(int)floorIndex;
- (NSNumber *)getNextFloor:(int)floorIndex;

- (BOOL)isDeviatingFromRoute:(NPLocalPoint *)point WithThrehold:(double)distance;

- (NSArray *)getRouteDirectionHintOnFloor:(NPMapInfo *)info;

- (NPDirectionalHint *)getDirectionHintForLocation:(NPLocalPoint *)location FromHints:(NSArray *)directions;

+ (AGSPolyline *)getSubPolyline:(AGSPolyline *)originalLine WithStart:(AGSPoint *)start End:(AGSPoint *)end;

@end
