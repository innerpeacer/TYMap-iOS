//
//  NPRouteManager.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "NPMapEnviroment.h"

@class NPRouteManager;

/**
 *  路径管理代理协议
 */
@protocol NPRouteManagerDelegate <NSObject>

/**
 *  获取默认参数失败回调方法
 *
 *  @param routeManager 路径管理实例
 *  @param error        错误信息
 */
- (void)routeManager:(NPRouteManager *)routeManager didFailRetrieveDefaultRouteTaskParametersWithError:(NSError *)error;

/**
 *  解决路径规划返回方法
 *
 *  @param routeManager       路径管理实例
 *  @param routeResultGraphic 路径规划结果
 */
- (void)routeManager:(NPRouteManager *)routeManager didSolveRouteWithResult:(AGSGraphic *)routeResultGraphic;

/**
 *  路径规划失败回调方法
 *
 *  @param routeManager 路径管理实例
 *  @param error        错误信息
 */
- (void)routeManager:(NPRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error;
@end

/**
 *  路径管理类
 */
@interface NPRouteManager : NSObject

/**
 *  路径规划起点
 */
@property (nonatomic, strong) AGSPoint *startPoint;

/**
 *  路径规划终点
 */
@property (nonatomic, strong) AGSPoint *endPoint;

/**
 *  路径管理代理
 */
@property (nonatomic, weak) id<NPRouteManagerDelegate> delegate;

/**
 *  路径管理类的静态实例化方法
 *
 *  @param url        路径服务URL
 *  @param credential 用户访问验证
 *
 *  @return 路径管理类实例
 */
+ (NPRouteManager *)routeManagerWithURL:(NSURL *)url credential:(AGSCredential *)credential;

/**
 *  请求路径规划，在代理方法获取规划结果
 *
 *  @param start 路径规划起点
 *  @param end   路径规划终点
 */
- (void)requestRouteWithStart:(AGSPoint *)start End:(AGSPoint *)end;

@end
