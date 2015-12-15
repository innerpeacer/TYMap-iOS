//
//  TYWebObjectConverter.m
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYWebObjectConverter.h"
#import <TYMapData/TYMapData.h>
#import "TYMapInfo.h"
#import "TYSyncMapDataRecord.h"
#import "TYSyncRouteRecord.h"

@implementation TYWebObjectConverter

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

+ (NSArray *)prepareMapDataObjectArray:(NSArray *)mapDataArray
{
    NSMutableArray *mapDataObjectArray = [NSMutableArray array];
    for (TYSyncMapDataRecord *record in mapDataArray) {
        NSDictionary *mapDataObject = [TYSyncMapDataRecord buildMapDataObject:record];
        [mapDataObjectArray addObject:mapDataObject];
    }
    return mapDataObjectArray;
}

+ (NSArray *)parseMapDataArray:(NSArray *)mapDataObjectArray
{
    NSMutableArray *mapDataArray = [NSMutableArray array];
    for (NSDictionary *mapDataObject in mapDataObjectArray) {
        TYSyncMapDataRecord *record = [TYSyncMapDataRecord parseMapDataRecord:mapDataObject];
        [mapDataArray addObject:record];
    }
    return mapDataArray;
}

+ (NSArray *)prepareRouteNodeObjectArray:(NSArray *)routeNodeArray
{
    NSMutableArray *routeNodeObjectArray = [NSMutableArray array];
    for (TYSyncRouteNodeRecord *record in routeNodeArray) {
        NSDictionary *routeNodeObject = [TYSyncRouteNodeRecord buildRouteNodeObject:record];
        [routeNodeObjectArray addObject:routeNodeObject];
    }
    return routeNodeObjectArray;
}

+ (NSArray *)parseRouteNodeArray:(NSArray *)routeNodeObjectArray
{
    NSMutableArray *routeNodeArray = [NSMutableArray array];
    for (NSDictionary *routeNodeObject in routeNodeObjectArray) {
        TYSyncRouteNodeRecord *record = [TYSyncRouteNodeRecord parseRouteNodeRecord:routeNodeObject];
        [routeNodeArray addObject:record];
    }
    return routeNodeArray;
}

+ (NSArray *)prepareRouteLinkObjectArray:(NSArray *)routeLinkArray
{
    NSMutableArray *routeLinkObjectArray = [NSMutableArray array];
    for (TYSyncRouteLinkRecord *record in routeLinkArray) {
        NSDictionary *routeLinkObject = [TYSyncRouteLinkRecord buildRouteLinkObject:record];
        [routeLinkObjectArray addObject:routeLinkObject];
    }
    return routeLinkObjectArray;
}

+ (NSArray *)parseRouteLinkArray:(NSArray *)routeLinkObjectArray
{
    NSMutableArray *routeLinkArray = [NSMutableArray array];
    for (NSDictionary *routeLinkObject in routeLinkObjectArray) {
        TYSyncRouteLinkRecord *record = [TYSyncRouteLinkRecord parseRouteLinkRecord:routeLinkObject];
        [routeLinkArray addObject:record];
    }
    return routeLinkArray;
}

@end
