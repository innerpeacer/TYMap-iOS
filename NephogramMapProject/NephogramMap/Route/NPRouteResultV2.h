//
//  NPRouteResultV2.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPRoutePart.h"
#import "NPDirectionalHint.h"

@interface NPRouteResultV2 : NSObject


@property (nonatomic, readonly) NSArray *allRoutePartsArray;
@property (nonatomic, readonly) NSDictionary *allFloorRoutePartDict;

+ (NPRouteResultV2 *)routeResultWithRouteParts:(NSArray *)routePartArray;

- (NSArray *)getRoutePartsOnFloor:(int)floor;

- (NPRoutePart *)getRoutePart:(int)index;

- (NSArray *)getRouteDirectionalHint:(NPRoutePart *)rp;

@end