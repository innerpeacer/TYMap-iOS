//
//  TYRouteLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#import "TYRouteResult.h"

@class TYMapView;

@class TYLocalPoint;


// *  路径导航层，用于显示导航路径
@interface IPRouteLayer : AGSGraphicsLayer

@property (nonatomic, weak) TYMapView *mapView;

@property (nonatomic, strong) TYRouteResult *routeResult;

@property (nonatomic, strong) TYLocalPoint *startPoint;
@property (nonatomic, strong) TYLocalPoint *endPoint;

@property (nonatomic, strong) AGSPictureMarkerSymbol *startSymbol;
@property (nonatomic, strong) AGSPictureMarkerSymbol *endSymbol;
@property (nonatomic, strong) AGSPictureMarkerSymbol *switchSymbol;


// *  路径导航层的静态实例化方法
// *
// *  @param sr 坐标系空间参考
// *
// *  @return 路径导航层

+ (IPRouteLayer *)routeLayerWithSpatialReference:(AGSSpatialReference *)sr;

- (NSArray *)showRouteResultOnFloor:(int)floor;
- (NSArray *)showPassedAndRemainingRouteResultOnFloor:(int)floor WithLocation:(TYLocalPoint *)location;
- (NSArray *)showRemainingRouteResultOnFloor:(int)floor WithLocation:(TYLocalPoint *)location;
- (TYRoutePart *)getNearestRoutePartWithLocation:(TYLocalPoint *)location;

- (void)reset;

- (void)showStartSymbol:(TYLocalPoint *)sp;
- (void)showEndSymbol:(TYLocalPoint *)ep;
- (void)showSwitchSymbol:(TYLocalPoint *)sp;

@end
