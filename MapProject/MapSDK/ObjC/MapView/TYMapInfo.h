//
//  TYMapInfo.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYBuilding;

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
@interface TYMapInfo : NSObject

/**
 *  所在城市的ID
 */
@property (nonatomic, readonly) NSString *cityID;


/**
 *  所在建筑的ID
 */
@property (nonatomic, readonly) NSString *buildingID;

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
 *  地图X方向放缩比例，当前比例为1
 */
@property (readonly) double scalex;

/**
 *  地图Y方向放缩比例，当前比例为1
 */
@property (readonly) double scaley;

/**
 *  解析目标建筑的特定名称的地图信息
 *
 *  @param floor    目标楼层名称
 *  @param building 目标建筑信息
 *
 *  @return 目标楼层地图信息
 */
+ (TYMapInfo *)parseMapInfo:(NSString *)floor ForBuilding:(TYBuilding *)building;

/**
 *  解析目标建筑的所有楼层地图信息
 *
 *  @param building 目标建筑
 *
 *  @return 目标楼层所有地图信息
 */
+ (NSArray *)parseAllMapInfo:(TYBuilding *)building;

/**
 *  从一组地图信息中搜索特定楼层的地图信息
 *
 *  @param array 目标地图信息数组
 *  @param floor 目标楼层
 *
 *  @return 目标楼层信息
 */
+ (TYMapInfo *)searchMapInfoFromArray:(NSArray *)array Floor:(int)floor;


+ (NSArray *)parseAllMapInfoFromFile:(NSString *)path;

@end
