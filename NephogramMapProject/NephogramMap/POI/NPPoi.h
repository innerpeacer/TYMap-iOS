//
//  NPPoi.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

/**
 *  POI类型，当前按层来分类：房间层（ROOM）、资产层（ASSET）、公共设施层（FACILITY）
 */
typedef enum
{
    POI_ROOM,
    POI_ASSET,
    POI_FACILITY
} POI_TYPE;

/**
 *  @brief POI类：用于表示POI相关数据，主要包含POI地理信息，及相应POI ID
 */
@interface NPPoi : NSObject

/**
 *  POI地理ID
 */
@property (nonatomic, strong) NSString *geoID;

/**
 *  @brief POI ID
 */
@property (nonatomic, strong) NSString *poiID;

/**
 *  POI所在楼层ID
 */
@property (nonatomic, strong) NSString *floorID;

/**
 *  POI所在建筑ID
 */
@property (nonatomic, strong) NSString *buildingID;

/**
 *  POI名称
 */
@property (nonatomic, strong) NSString *name;

/**
 *  POI几何数据
 */
@property (nonatomic, strong) AGSGeometry *geometry;

/**
 *  POI分类类型ID
 */
@property (nonatomic, readonly) int categoryID;

/**
 *  POI类型
 */
@property (nonatomic, readonly) POI_TYPE type;


/**
 *  @discussion 创建POI实例的静态方法
 *  @return POI实例
 */
+ (NPPoi *)poiWithGeoID:(NSString *)gid PoiID:(NSString *)pid FloorID:(NSString *)fid  BuildingID:(NSString *)bid Name:(NSString *)pname Geometry:(AGSGeometry *)geometry CategoryID:(int)cid Type:(POI_TYPE)ptype;

@end
