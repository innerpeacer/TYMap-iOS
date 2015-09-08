#import <Foundation/Foundation.h>

typedef struct offsetSize {
    double x;
    double y;
} OffsetSize;

/**
 * 建筑类，表示整栋建筑的信息
 */
@interface TYBuilding : NSObject

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
@property (readonly) OffsetSize offset;

/**
 * 建筑状态
 */
@property (assign) int status;


- (id)initWithCityID:(NSString *)cityID BuildingID:(NSString *)buildingID Name:(NSString *)name Lon:(double)lon Lat:(double)lat Address:(NSString *)address InitAngle:(double)initAngle RouteURL:(NSString *)url Offset:(OffsetSize)offset;

@end
