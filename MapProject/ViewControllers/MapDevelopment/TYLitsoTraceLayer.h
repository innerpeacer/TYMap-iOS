//
//  TYTraceLayerV2.h
//  MapProject
//
//  Created by innerpeacer on 2016/11/26.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYTraceLocalPoint.h"

#import "TYSnappingManager.h"

@interface TYLitsoTraceLayer : AGSGraphicsLayer

- (void)setFloor:(int)floor;
- (void)addTracePoints:(NSArray *)pointArray WithThemes:(NSDictionary *)themes;
- (void)reset;
- (void)showSnappedTraces:(TYSnappingManager *)snappingManager;

@end
