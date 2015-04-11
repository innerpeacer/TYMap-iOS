#import <Foundation/Foundation.h>

/**
 * 建筑类
 */
@interface NPBuilding : NSObject

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
 * 建筑状态
 */
@property (assign) int status;


/**
 *  解析所有建筑信息列表
 *
 *  @param cityID 城市ID
 *
 *  @return 建筑类数组
 */
+ (NSArray *)parseAllBuildingsInCity:(NSString *)cityID;

/**
 *  按ID解析特定建筑信息
 *
 *  @param buildingID 建筑ID
 *  @param cityID     城市ID
 *
 *  @return 建筑类
 */
+ (NPBuilding *)parseBuilding:(NSString *)buildingID InCity:(NSString *)cityID;

@end
