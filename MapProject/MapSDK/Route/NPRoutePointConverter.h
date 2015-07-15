//
//  NPRoutePointConverter.h
//  MapProject
//
//  Created by innerpeacer on 15/3/18.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import <NephogramData/NephogramData.h>
#import "NPMapInfo.h"
#import "NPPoint.h"

/**
    导航点转换类
 */
@interface NPRoutePointConverter : NSObject

/**
 *  导航点转换类初始化方法
 *
 *  @param extent 基础地图范围
 *  @param offset 地图偏移量
 *
 *  @return 导航点转换类实例
 */
- (id)initWithBaseMapExtent:(MapExtent)extent Offset:(MapSize)offset;

/**
 *  将实际坐标点转换成导航坐标点
 *
 *  @param localPoint 目标坐标点
 *
 *  @return 相应的导航坐标点
 */
- (NPPoint *)routePointFromLocalPoint:(NPLocalPoint *)localPoint;

/**
 *  将导航坐标眯转换成实际坐标点
 *
 *  @param routePoint 目标导航坐标点
 *
 *  @return 相应的实际坐标点
 */
- (NPLocalPoint *)localPointFromRoutePoint:(NPPoint *)routePoint;

/**
 *  检测坐标点的有效性
 *
 *  @param point 目标坐标点
 *
 *  @return 是否有效
 */
- (BOOL)checkPointValidity:(NPLocalPoint *)point;

@end
