//
//  TYTraceLayerV2.h
//  MapProject
//
//  Created by innerpeacer on 2016/11/26.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>
#import "TYSnappingManager.h"

@interface TYTraceLayerV2 : AGSGraphicsLayer

- (void)setFloor:(int)floor;
- (void)addTracePoint:(TYLocalPoint *)point;
- (void)addTracePoints:(NSArray *)pointArray;
- (void)reset;
- (void)showTraces;
- (void)showSnappedTraces:(TYSnappingManager *)snappingManager;

@end
