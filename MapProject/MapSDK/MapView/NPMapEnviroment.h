//
//  NPMapEnviroment.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYCredential.h"
#import "TYSpatialReference.h"

/**
    地图显示的语言类型
 */
typedef enum {
    NPSimplifiedChinese, NPTraditionalChinese, NPEnglish
} NPMapLanguage;



/**
 *  地图环境
 */
@interface NPMapEnvironment : NSObject

/**
 *  默认坐标系空间参考
 *
 *  @return WKID:3395
 */
+ (TYSpatialReference *)defaultSpatialReference;


/**
 *  访问地图服务的默认用户验证
 *
 *  @return [user:password] --> ["arcgis":"666666"]
 */
+ (TYCredential *)defaultCredential;


/**
 *  初始化运行时环境，在调用任何地图SDK方法前调用此方法
 */
+ (void)initMapEnvironment;

/**
 *  设置当前地图文件的根目录
 *
 *  @param dir 文件根目录
 */
+ (void)setRootDirectoryForMapFiles:(NSString *)dir;

/**
 *  获取当前地图文件的根目录
 *
 *  @return 根目录字符串
 */
+ (NSString *)getRootDirectoryForMapFiles;

/**
 *  设置当前地图显示的语言类型
 *
 *  @param language 目标语言类型
 */
+ (void)setMapLanguage:(NPMapLanguage)language;

/**
 *  获取当前地图显示的语言类型
 *
 *  @return 当前语言类型
 */
+ (NPMapLanguage)getMapLanguage;

@end
