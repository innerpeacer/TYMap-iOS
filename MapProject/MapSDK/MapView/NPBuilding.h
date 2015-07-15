#import <Foundation/Foundation.h>
#import "NPCity.h"
#import "NPMapInfo.h"

/**
 * 建筑类，表示整栋建筑的信息
 */
@interface NPBuilding : NSObject

/**
 *  建筑所在城市ID
 */
@property (nonatomic, strong) NSString *cityID;

/**
 * 建筑ID
 */
@property (nonatomic, strong) NSString *buildingID;

/**
 * 建筑名称
 */
@property (nonatomic, strong) NSString *name;

/**
 * 建筑地址
 */
@property (nonatomic, strong) NSString *address;

/**
 * 建筑经度
 */
@property (readonly) double longitude;

/**
 * 建筑纬度
 */
@property (readonly) double latitude;

/**
 *  地图初始偏转角度
 */
@property (readonly) double initAngle;

/**
 *  导航服务地址
 */
@property (nonatomic, strong) NSString *routeURL;

/**
 *  导航偏移量
 */
@property (readonly) MapSize offset;

/**
 * 建筑状态
 */
@property (assign) int status;

/**
 *  解析目标城市的所有建筑信息
 *
 *  @param city 目标城市
 *
 *  @return 建筑信息数组
 */
+ (NSArray *)parseAllBuildings:(NPCity *)city;

/**
 *  解析目标城市特定ID的建筑信息
 *
 *  @param buildingID 目标建筑ID
 *  @param city       目标城市
 *
 *  @return 目标建筑信息
 */
+ (NPBuilding *)parseBuilding:(NSString *)buildingID InCity:(NPCity *)city;

@end
