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
#import "NPPoint.h"
#import "NPCallout.h"
#import "NPGraphic.h"
#import "NPGraphicsLayer.h"
#import "NPLocationDisplay.h"
#import "NPMarkerSymbol.h"
#import <NephogramData/NPLocalPoint.h>

typedef enum {
    NPMapViewModeDefault = 0,
    NPMapViewModeFollowing = 1
} NPMapViewMode;

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
- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(NPPoint *)mappoint;

/**
 *  地图POI选中事件回调
 *
 *  @param mapView 地图视图
 *  @param array   选中的POI数组:[NPPoi]
 */
- (void)NPMapView:(NPMapView *)mapView PoiSelected:(NSArray *)array;


/**
 *  地图楼层加载完成回调
 *
 *  @param mapView 地图视图
 *  @param mapInfo 加载楼层信息
 */
- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo;


@optional
- (void)NPMapViewDidLoad:(NPMapView *)mapView;

- (void)NPMapView:(NPMapView *)mapView calloutDidDismiss:(NPCallout *)callout;

- (void)NPMapView:(NPMapView *)mapView calloutWillDismiss:(NPCallout *)callout;

- (BOOL)NPMapView:(NPMapView *)mapView willShowForGraphic:(NPGraphic *)graphic layer:(NPGraphicsLayer *)layer mapPoint:(NPPoint *)mappoint;

//- (BOOL)NPMapView:(NPMapView *)mapView callout:(NPCallout *)callout willShowForLocationDisplay:(NPLocationDisplay *)locationDisplay;
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
@property (nonatomic, readonly) NPMapInfo *currentMapInfo;

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

- (void)setLocationSymbol:(NPMarkerSymbol *)symbol;

- (void)showLocation:(NPLocalPoint *)location;

- (void)removeLocation;

- (void)processDeviceRotation:(double)newHeading;

- (void)setMapMode:(NPMapViewMode)mode;

/**
 *  地图初始化方法
 *
 *  @param renderingScheme 地图渲染方案
 */
- (void)initMapViewWithRenderScheme:(NPRenderingScheme *)renderingScheme;

/**
 *  移动地图将特定坐标限定在特定屏幕范围内
 *
 *  @param location 目标点地图坐标
 *  @param range 目标屏幕范围
 *
 */
- (void)restrictLocation:(NPPoint *)location toScreenRange:(CGRect)range;

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

/**
 *  显示当前楼层的特定类型公共设施
 *
 *  @param categoryIDs 公共设施类型ID数组
 */
- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs;

/**
 *  获取当前楼层下特定子层特定poiID的信息
 *
 *  @param pid   poiID
 *  @param layer 目标子层
 *
 *  @return poi信息
 */
- (NPPoi *)getPoiOnCurrentFloorWithPoiID:(NSString *)pid layer:(POI_LAYER)layer;

/**
 *  高亮显示POI
 *
 *  @param poi 目标poi
 *  目标poi至少包含poiID和layer信息，当前支持ROOM和FACILITY高亮
 */
- (void)highlightPoi:(NPPoi *)poi;

/**
 *  高亮显示一组POI
 *
 *  @param poiArray 目标poi数组
 */
- (void)highlightPois:(NSArray *)poiArray;

/**
 *  根据坐标x和y提取当前楼层的ROOM POI
 *
 *  @param x 坐标x
 *  @param y 坐标y
 *
 *  @return ROOM POI
 */
- (NPPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y;

@end

