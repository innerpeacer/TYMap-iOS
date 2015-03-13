#import <Foundation/Foundation.h>

/**
 *  城市类
 */
@interface NPCity : NSObject

/**
 *  城市ID
 */
@property (nonatomic, strong) NSString *cityID;

/**
 *  城市名称
 */
@property (nonatomic, strong) NSString *name;

/**
 *  城市简称
 */
@property (nonatomic, strong) NSString *sname;

/**
 *  城市经度
 */
@property (readonly) double longitude;

/**
 *  城市纬度
 */
@property (readonly) double latitude;

/**
 *  当前状态
 *
 */
@property (assign) int status;

/**
 *  解析所有城市信息信息列表
 *
 *  @return 城市类数组
 */
+ (NSArray *)parseAllCities;

/**
 *  解析特定城市信息
 *
 *  @param cityID 城市ID
 *
 *  @return 城市类
 */
+ (NPCity *)parseCity:(NSString *)cityID;

@end
