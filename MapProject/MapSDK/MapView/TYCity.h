#import <Foundation/Foundation.h>

/**
 *  城市类
 */
@interface TYCity : NSObject

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
 *  解析所有城市信息列表
 *
 *  @return 所有城市信息数组
 */
+ (NSArray *)parseAllCities;

/**
 *  解析目标城市信息
 *
 *  @param cityID 目标城市ID
 *
 *  @return 目标城市信息
 */
+ (TYCity *)parseCity:(NSString *)cityID;

@end
