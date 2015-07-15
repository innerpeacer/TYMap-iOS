//
//  NPRenderingScheme.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPSimpleFillSymbol.h"
#import "NPSimpleLineSymbol.h"

/**
 *  渲染方案类：用于表示地图的渲染规则
 */
@interface NPRenderingScheme : NSObject

/**
 *  渲染方案初始化方法
 *
 *  @param path 渲染方案文件路径
 *
 *  @return 渲染方案实例
 */
- (id)initWithPath:(NSString *)path;

/**
 *  默认填充符号
 */
@property (nonatomic, strong) NPSimpleFillSymbol *defaultFillSymbol;

/**
 *  默认高亮填充符号
 */
@property (nonatomic, strong) NPSimpleFillSymbol *defaultHighlightFillSymbol;

/**
 *  默认线型符号
 */
@property (nonatomic, strong) NPSimpleLineSymbol *defaultLineSymbol;

/**
 *  默认高亮线型符号
 */
@property (nonatomic, strong) NPSimpleLineSymbol *defaultHighlightLineSymbol;

/**
 *  填充符号字典，{NSNumber: FillSymbol} -> {类型: 填充符号}
 */
@property (nonatomic, strong) NSDictionary *fillSymbolDictionary;

/**
 *  Icon符号字典，{NSNumber: NSString} -> {类型: Icon文件名}
 */
@property (nonatomic, strong) NSDictionary *iconSymbolDictionary;

@end

