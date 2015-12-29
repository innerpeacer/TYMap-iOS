//
//  TYWebObjectConverter.m
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPMapWebObjectConverter.h"
#import <TYMapData/TYMapData.h>
#import "TYMapInfo.h"
#import "IPSyncMapDataRecord.h"
#import "IPSyncRouteRecord.h"
#import "IPSyncSymbolRecord.h"

@implementation IPMapWebObjectConverter

+ (NSString *)prepareJsonString:(id)jsonObject
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (id)parseJsonOjbect:(NSData *)jsonData
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    return jsonObject;
}

+ (NSArray *)prepareCityObjectArray:(NSArray *)cityArray
{
    NSMutableArray *cityOjbectArray = [NSMutableArray array];
    for (TYCity *city in cityArray) {
        NSDictionary *cityObject = [TYCity buildCityObject:city];
        [cityOjbectArray addObject:cityObject];
    }
    return cityOjbectArray;
}

+ (NSArray *)parseCityArray:(NSArray *)cityObjectArray
{
    NSMutableArray *cityArray = [NSMutableArray array];
    for (NSDictionary *cityObject in cityObjectArray) {
        TYCity *city = [TYCity parseCityObject:cityObject];
        [cityArray addObject:city];
    }
    return cityArray;
}

+ (NSArray *)prepareBuildingObjectArray:(NSArray *)buildingArray
{
    NSMutableArray *buildingObjectArray = [NSMutableArray array];
    for (TYBuilding *building in buildingArray) {
        NSDictionary *buildingObject = [TYBuilding buildBuildingObject:building];
        [buildingObjectArray addObject:buildingObject];
    }
    return buildingObjectArray;
}

+ (NSArray *)parseBuildingArray:(NSArray *)buildingObjectArray
{
    NSMutableArray *buildingArray = [NSMutableArray array];
    for (NSDictionary *buildingObject in buildingObjectArray) {
        TYBuilding *building = [TYBuilding parseBuildingObject:buildingObject];
        [buildingArray addObject:building];
    }
    return buildingArray;

}

+ (NSArray *)prepareMapInfoObjectArray:(NSArray *)mapInfoArray
{
    NSMutableArray *mapInfoObjectArray = [NSMutableArray array];
    for (TYMapInfo *info in mapInfoArray) {
        NSDictionary *mapInfoObject = [TYMapInfo buildingMapInfoObject:info];
        [mapInfoObjectArray addObject:mapInfoObject];
    }
    return mapInfoObjectArray;
}

+ (NSArray *)parseMapInfoArray:(NSArray *)mapInfoObjectArray
{
    NSMutableArray *mapInfoArray = [NSMutableArray array];
    for (NSDictionary *mapInfoObject in mapInfoObjectArray) {
        TYMapInfo *mapInfo = [TYMapInfo parseMapInfoObject:mapInfoObject];
        [mapInfoArray addObject:mapInfo];
    }
    return mapInfoArray;
}

+ (NSArray *)prepareFillSymbolObjectArray:(NSArray *)fillSymbolArray
{
    NSMutableArray *fillSymbolObjectArray = [NSMutableArray array];
    for (IPSyncFillSymbolRecord *fillSymbol in fillSymbolArray) {
        NSDictionary *fillSymbolObject = [IPSyncFillSymbolRecord buildFillSymbolObject:fillSymbol];
        [fillSymbolObjectArray addObject:fillSymbolObject];
    }
    return fillSymbolObjectArray;
}

+ (NSArray *)parseFillSymbolArray:(NSArray *)fillSymbolObjectArray
{
    NSMutableArray *fillSymbolArray = [NSMutableArray array];
    for (NSDictionary *fillSymbolObject in fillSymbolObjectArray) {
        IPSyncFillSymbolRecord *fillSymbol = [IPSyncFillSymbolRecord parseFillSymbolRecord:fillSymbolObject];
        [fillSymbolArray addObject:fillSymbol];
    }
    return fillSymbolArray;
}

+ (NSArray *)prepareIconSymbolObjectArray:(NSArray *)iconSymbolArray
{
    NSMutableArray *iconSymbolObjectArray = [NSMutableArray array];
    for (IPSyncIconSymbolRecord *iconSymbol in iconSymbolArray) {
        NSDictionary *iconSymbolObject = [IPSyncIconSymbolRecord buildIconSymbolObject:iconSymbol];
        [iconSymbolObjectArray addObject:iconSymbolObject];
    }
    return iconSymbolObjectArray;
}

+ (NSArray *)parseIconSymbolArray:(NSArray *)iconSymbolObjectArray
{
    NSMutableArray *iconSymbolArray = [NSMutableArray array];
    for (NSDictionary *iconSymbolObject in iconSymbolObjectArray) {
        IPSyncIconSymbolRecord *iconSymbol = [IPSyncIconSymbolRecord parseIconSymbolRecord:iconSymbolObject];
        [iconSymbolArray addObject:iconSymbol];
    }
    return iconSymbolArray;
}


+ (NSArray *)prepareMapDataObjectArray:(NSArray *)mapDataArray
{
    NSMutableArray *mapDataObjectArray = [NSMutableArray array];
    for (IPSyncMapDataRecord *record in mapDataArray) {
        NSDictionary *mapDataObject = [IPSyncMapDataRecord buildMapDataObject:record];
        [mapDataObjectArray addObject:mapDataObject];
    }
    return mapDataObjectArray;
}

+ (NSArray *)parseMapDataArray:(NSArray *)mapDataObjectArray
{
    NSMutableArray *mapDataArray = [NSMutableArray array];
    for (NSDictionary *mapDataObject in mapDataObjectArray) {
        IPSyncMapDataRecord *record = [IPSyncMapDataRecord parseMapDataRecord:mapDataObject];
        [mapDataArray addObject:record];
    }
    return mapDataArray;
}

+ (NSArray *)prepareRouteNodeObjectArray:(NSArray *)routeNodeArray
{
    NSMutableArray *routeNodeObjectArray = [NSMutableArray array];
    for (IPSyncRouteNodeRecord *record in routeNodeArray) {
        NSDictionary *routeNodeObject = [IPSyncRouteNodeRecord buildRouteNodeObject:record];
        [routeNodeObjectArray addObject:routeNodeObject];
    }
    return routeNodeObjectArray;
}

+ (NSArray *)parseRouteNodeArray:(NSArray *)routeNodeObjectArray
{
    NSMutableArray *routeNodeArray = [NSMutableArray array];
    for (NSDictionary *routeNodeObject in routeNodeObjectArray) {
        IPSyncRouteNodeRecord *record = [IPSyncRouteNodeRecord parseRouteNodeRecord:routeNodeObject];
        [routeNodeArray addObject:record];
    }
    return routeNodeArray;
}

+ (NSArray *)prepareRouteLinkObjectArray:(NSArray *)routeLinkArray
{
    NSMutableArray *routeLinkObjectArray = [NSMutableArray array];
    for (IPSyncRouteLinkRecord *record in routeLinkArray) {
        NSDictionary *routeLinkObject = [IPSyncRouteLinkRecord buildRouteLinkObject:record];
        [routeLinkObjectArray addObject:routeLinkObject];
    }
    return routeLinkObjectArray;
}

+ (NSArray *)parseRouteLinkArray:(NSArray *)routeLinkObjectArray
{
    NSMutableArray *routeLinkArray = [NSMutableArray array];
    for (NSDictionary *routeLinkObject in routeLinkObjectArray) {
        IPSyncRouteLinkRecord *record = [IPSyncRouteLinkRecord parseRouteLinkRecord:routeLinkObject];
        [routeLinkArray addObject:record];
    }
    return routeLinkArray;
}

@end
