//
//  NPMapView.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPMapInfo.h"
#import "NPPoi.h"
#import "NPRenderingScheme.h"

@class NPMapView;

/**
 *  地图代理协议
 */
@protocol NPMapViewDelegate <NSObject>

/**
 *  地图点选事件回调方法
 *
 *  @param mapView  地图视图
 *  @param screen   点击事件的屏幕坐标
 *  @param mappoint 点击事件的地图坐标
 */
- (void)CAMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint;

/**
 *  地图POI选中事件回调
 *
 *  @param mapView 地图视图
 *  @param array   选中的POI数组:[CAPoi]
 */
- (void)CAMapView:(NPMapView *)mapView PoiSelected:(NSArray *)array;

@end

/**
 *  地图视图类
 */
@interface NPMapView : AGSMapView

/**
 *  地图代理，用于处理地图点击、Poi点选事件
 */
@property (nonatomic, weak) id<NPMapViewDelegate> mapDelegate;

/**
 *  当前显示的建筑ID
 */
@property (nonatomic, strong) NSString *buildingID;

/**
 *  当前建筑的当前楼层信息
 */
@property (nonatomic, strong) NPMapInfo *currentMapInfo;

/**
 *  在POI被点选时是否高亮显示，默认为NO
 */
@property (nonatomic, assign) BOOL highlightPOIOnSelection;

/**
 *  切换楼层方法
 *
 *  @param info 目标楼层的地图信息
 */
- (void)setFloorWithInfo:(NPMapInfo *)info;


/**
 *  地图初始化方法
 *
 *  @param renderScheme 地图渲染方案
 */
- (void)initMapViewWithRenderScheme:(NPRenderingScheme *)renderingScheme;

/**
 *  清除高亮显示的POI
 */
- (void)clearSelection;

/**
 *  返回当前楼层的所有公共设施类型
 *
 *  @return 公共设施类型数组:[NSNumber]
 */
- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor;

/**
 *  显示当前楼层的所有公共设施
 */
- (void)showAllFacilitiesOnCurrentFloor;

/**
 *  显示当前楼层的特定类型公共设施
 *
 *  @param categoryID 公共设施类型ID
 */
- (void)showFacilityOnCurrentWithCategory:(int)categoryID;

@end
