//
//  NPRoutePart.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "NPMapInfo.h"

@interface NPRoutePart : NSObject

//- (id)initWithRouteLine:(AGSPolyline *)route Floor:(int)floor;
- (id)initWithRouteLine:(AGSPolyline *)route MapInfo:(NPMapInfo *)mapInfo;


@property (nonatomic, strong, readonly) AGSPolyline *route;
//@property (nonatomic, assign, readonly) int floor;
@property (nonatomic, strong, readonly) NPMapInfo *info;

@property (nonatomic, weak) NPRoutePart *previousPart;
@property (nonatomic, weak) NPRoutePart *nextPart;

- (BOOL)isFirstPart;
- (BOOL)isLastPart;
- (BOOL)isMiddlePart;

- (AGSPoint *)getFirstPoint;
- (AGSPoint *)getLastPoint;

@end
