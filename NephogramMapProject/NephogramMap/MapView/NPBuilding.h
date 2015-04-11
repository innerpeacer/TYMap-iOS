#import <Foundation/Foundation.h>
#import "NPCity.h"

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


+ (NSArray *)parseAllBuildings:(NPCity *)city;
+ (NPBuilding *)parseBuilding:(NSString *)buildingID InCity:(NPCity *)city;

@end
