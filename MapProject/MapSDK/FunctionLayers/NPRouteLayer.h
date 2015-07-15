//
//  NPRouteLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#import "TYSpatialReference.h"
#import "TYPictureMarkerSymbol.h"
#import "NPRouteResult.h"

@class NPMapView;

@class NPLocalPoint;

/**
 *  路径导航层，用于显示导航路径
 */
@interface NPRouteLayer : AGSGraphicsLayer

@property (nonatomic, weak) NPMapView *mapView;

@property (nonatomic, strong) NPRouteResult *routeResult;

@property (nonatomic, strong) NPLocalPoint *startPoint;
@property (nonatomic, strong) NPLocalPoint *endPoint;

@property (nonatomic, strong) TYPictureMarkerSymbol *startSymbol;
@property (nonatomic, strong) TYPictureMarkerSymbol *endSymbol;
@property (nonatomic, strong) TYPictureMarkerSymbol *switchSymbol;

/**
 *  路径导航层的静态实例化方法
 *
 *  @param sr 坐标系空间参考
 *
 *  @return 路径导航层
 */
+ (NPRouteLayer *)routeLayerWithSpatialReference:(TYSpatialReference *)sr;

- (NSArray *)showRouteResultOnFloor:(int)floor;

- (NSArray *)showRemainingRouteResultOnFloor:(int)floor WithLocation:(NPLocalPoint *)location;
- (NPRoutePart *)getNearestRoutePartWithLocation:(NPLocalPoint *)location;

- (void)reset;

- (void)showStartSymbol:(NPLocalPoint *)sp;
- (void)showEndSymbol:(NPLocalPoint *)ep;
- (void)showSwitchSymbol:(NPLocalPoint *)sp;

@end
