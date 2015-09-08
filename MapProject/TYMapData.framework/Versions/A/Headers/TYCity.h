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

- (id)initWithCityID:(NSString *)cityId Name:(NSString *)name SName:(NSString *)sname Lon:(double)lon Lat:(double)lat;


@end
