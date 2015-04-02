//
//  NPRouteLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#import "NPSpatialReference.h"


/**
 *  路径导航层，用于显示导航路径
 */
@interface NPRouteLayer : AGSGraphicsLayer

/**
 *  路径导航层的静态实例化方法
 *
 *  @param sr 坐标系空间参考
 *
 *  @return 路径导航层
 */
+ (NPRouteLayer *)routeLayerWithSpatialReference:(NPSpatialReference *)sr;

@end
