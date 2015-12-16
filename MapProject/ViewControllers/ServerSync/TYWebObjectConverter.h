//
//  TYWebObjectConverter.h
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYWebObjectConverter : NSObject

+ (NSString *)prepareJsonString:(id)jsonObject;
+ (id)parseJsonOjbect:(NSData *)jsonData;

+ (NSArray *)prepareCityObjectArray:(NSArray *)cityArray;
+ (NSArray *)parseCityArray:(NSArray *)cityObjectArray;

+ (NSArray *)prepareBuildingObjectArray:(NSArray *)buildingArray;
+ (NSArray *)parseBuildingArray:(NSArray *)buildingObjectArray;

+ (NSArray *)prepareMapInfoObjectArray:(NSArray *)mapInfoArray;
+ (NSArray *)parseMapInfoArray:(NSArray *)mapInfoObjectArray;

+ (NSArray *)prepareFillSymbolObjectArray:(NSArray *)fillSymbolArray;
+ (NSArray *)parseFillSymbolArray:(NSArray *)fillSymbolObjectArray;

+ (NSArray *)prepareIconSymbolObjectArray:(NSArray *)iconSymbolArray;
+ (NSArray *)parseIconSymbolArray:(NSArray *)iconSymbolObjectArray;

+ (NSArray *)prepareMapDataObjectArray:(NSArray *)mapDataArray;
+ (NSArray *)parseMapDataArray:(NSArray *)mapDataObjectArray;

+ (NSArray *)prepareRouteNodeObjectArray:(NSArray *)routeNodeArray;
+ (NSArray *)parseRouteNodeArray:(NSArray *)routeNodeObjectArray;

+ (NSArray *)prepareRouteLinkObjectArray:(NSArray *)routeLinkArray;
+ (NSArray *)parseRouteLinkArray:(NSArray *)routeLinkObjectArray;

@end
