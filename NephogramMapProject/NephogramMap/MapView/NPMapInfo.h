//
//  NPMapInfo.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  地图尺寸,对应地图所示区域实际大小
 */
typedef struct mapsize {
    double x;
    double y;
} MapSize;

/**
 *  地图坐标范围:{xmin, ymin, xmax, ymax}
 */
typedef struct mapextent {
    double xmin;
    double ymin;
    double xmax;
    double ymax;
} MapExtent;

/**
 *  地图信息类：用于表示某一层地图的配置信息，包含地图ID、地图尺寸、地图范围、地图偏转角等
 */
@interface NPMapInfo : NSObject

/**
 *  当前地图的唯一ID，当前与楼层的FloorID一致
 */
@property (nonatomic, readonly) NSString *mapID;

/**
 *  地图尺寸
 */
@property (readonly) MapSize mapSize;

/**
 *  地图范围
 */
@property (readonly) MapExtent mapExtent;

/**
 *  当前楼层名称，如F1、B1
 */
@property (readonly, nonatomic) NSString *floorName;

/**
 *  当前楼层序号,如-1、1
 */
@property (readonly) int floorNumber;

/**
 *
 */
@property (readonly) double scalex;

/**
 *
 */
@property (readonly) double scaley;

/**
 *  地图初始偏转角度
 */
@property (readonly) double initAngle;

/**
 *  解析某楼层地图信息的静态方法
 *
 *  @param floor      楼层名称，如F1
 *  @param buildingID 楼层所在建筑的ID
 *
 *  @return 楼层地图信息
 */
+ (NPMapInfo *)parseMapInfo:(NSString *)floor ForBuilding:(NSString *)buildingID Path:(NSString *)path;


/**
 *  解析某建筑所有楼层的地图信息
 *
 *  @param buildingID 楼层所在建筑的ID
 *
 *  @return 所有楼层的地图信息数组:[NPMapInfo]
 */
+ (NSArray *)parseAllMapInfoForBuilding:(NSString *)buildingID Path:(NSString *)path;

@end
