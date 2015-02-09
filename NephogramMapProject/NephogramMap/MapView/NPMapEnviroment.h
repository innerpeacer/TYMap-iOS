//
//  NPMapEnviroment.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

/**
 *  地图环境
 */
@interface NPMapEnvironment : NSObject

/**
 *  默认坐标系空间参考
 *
 *  @return WKID:3395
 */
+ (AGSSpatialReference *)defaultSpatialReference;


/**
 *  访问地图服务的默认用户验证
 *
 *  @return [user:password] --> ["arcgis":"666666"]
 */
+ (AGSCredential *)defaultCredential;


/**
 *  初始化运行时环境，在调用任何地图SDK方法前调用此方法
 */
+ (void)initMapEnvironment;

@end
