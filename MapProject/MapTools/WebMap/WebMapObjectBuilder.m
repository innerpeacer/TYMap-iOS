//
//  WebMapBuilder.m
//  MapProject
//
//  Created by innerpeacer on 16/1/25.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "WebMapObjectBuilder.h"
#import "WebMapFields.h"
#import "SymbolRecord.h"

@implementation WebMapObjectBuilder

+ (id)generateWebBuildingObject:(TYBuilding *)building
{
    NSMutableDictionary *buildingObject = [[NSMutableDictionary alloc] init];
    [buildingObject setObject:building.cityID forKey:KEY_BUILDING_CITY_ID];
    [buildingObject setObject:building.buildingID forKey:KEY_BUILDING_ID];
    [buildingObject setObject:building.name forKey:KEY_BUILDING_NAME];
    [buildingObject setObject:@(building.longitude) forKey:KEY_BUILDING_LONGITUDE];
    [buildingObject setObject:@(building.latitude) forKey:KEY_BUILDING_LATITUDE];
    [buildingObject setObject:building.address forKey:KEY_BUILDING_ADDRESS];
    [buildingObject setObject:@(building.initAngle) forKey:KEY_BUILDING_INIT_ANGLE];
    [buildingObject setObject:building.routeURL forKey:KEY_BUILDING_ROUTE_URL];
    [buildingObject setObject:@(building.offset.x) forKey:KEY_BUILDING_OFFSET_X];
    [buildingObject setObject:@(building.offset.y) forKey:KEY_BUILDING_OFFSET_Y];
    [buildingObject setObject:@(building.status) forKey:KEY_BUILDING_STATUS];
    return buildingObject;
}

+ (id)generateWebCityObject:(TYCity *)city
{
    NSMutableDictionary *cityObject = [[NSMutableDictionary alloc] init];
    [cityObject setObject:city.cityID forKey:KEY_CITY_ID];
    [cityObject setObject:city.name forKey:KEY_CITY_NAME];
    [cityObject setObject:city.sname forKey:KEY_CITY_SHORT_NAME];
    [cityObject setObject:@(city.longitude) forKey:KEY_CITY_LONGITUDE];
    [cityObject setObject:@(city.latitude) forKey:KEY_CITY_LATITUDE];
    [cityObject setObject:@(city.status) forKey:KEY_CITY_STATUS];
    return cityObject;
}

+ (id)generateWebMapInfoObject:(TYMapInfo *)mapInfo
{
    NSMutableDictionary *mapInfoObject = [[NSMutableDictionary alloc] init];
    [mapInfoObject setObject:mapInfo.cityID forKey:KEY_MAPINFO_CITYID];
    [mapInfoObject setObject:mapInfo.buildingID forKey:KEY_MAPINFO_BUILDINGID];
    [mapInfoObject setObject:mapInfo.mapID forKey:KEY_MAPINFO_MAPID];
    [mapInfoObject setObject:mapInfo.floorName forKey:KEY_MAPINFO_FLOOR];
    [mapInfoObject setObject:@(mapInfo.floorNumber) forKey:KEY_MAPINFO_FLOOR_INDEX];
    [mapInfoObject setObject:@(mapInfo.mapSize.x) forKey:KEY_MAPINFO_SIZEX];
    [mapInfoObject setObject:@(mapInfo.mapSize.y) forKey:KEY_MAPINFO_SIZEY];
    [mapInfoObject setObject:@(mapInfo.mapExtent.xmin) forKey:KEY_MAPINFO_XMIN];
    [mapInfoObject setObject:@(mapInfo.mapExtent.xmax) forKey:KEY_MAPINFO_XMAX];
    [mapInfoObject setObject:@(mapInfo.mapExtent.ymin) forKey:KEY_MAPINFO_YMIN];
    [mapInfoObject setObject:@(mapInfo.mapExtent.ymax) forKey:KEY_MAPINFO_YMAX];
    return mapInfoObject;
}

+ (id)generateWebRenderingSchemeObjectWithFill:(NSDictionary *)fDict Icon:(NSDictionary *)iDict
{
    NSMutableDictionary *renderingSchemeObject = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *fillDict = [NSMutableDictionary dictionaryWithDictionary:fDict];
    NSMutableDictionary *iconDict = [NSMutableDictionary dictionaryWithDictionary:iDict];
    
    NSMutableDictionary *defaultSymbol = [[NSMutableDictionary alloc] init];
    {
        NSArray *defaultArray = @[@(9999), @(9998), @(9997), @(9996)];
        NSArray *defaultKey = @[KEY_DEFAULT_FILL_SYMBOL, KEY_DEFAULT_HIGHLIGHT_FILL_SYMBOL, KEY_DEFAULT_LINE_SYMBOL, KEY_DEFAULT_HIGHLIGHT_LINE_SYMBOL];
        for (int i = 0; i < defaultArray.count; ++i) {
            NSNumber *defaultID = defaultArray[i];
            FillSymbolRecord *defaultFillSymbolRecord = [fillDict objectForKey:defaultID];
            if (defaultFillSymbolRecord) {
                [defaultSymbol setObject:[defaultFillSymbolRecord buildWebFillObject] forKey:defaultKey[i]];
                [fillDict removeObjectForKey:defaultID];
            }
        }
    }
    [renderingSchemeObject setObject:defaultSymbol forKey:KEY_DEFAULT_SYMBOL];
    
    NSMutableArray *fillSymbol = [[NSMutableArray alloc] init];
    {
        for(FillSymbolRecord *fillRecord in fillDict.allValues) {
            [fillSymbol addObject:[fillRecord buildWebFillObject]];
        }
    }
    [renderingSchemeObject setObject:fillSymbol forKey:KEY_FILL_SYMBOL];
    
    NSMutableArray *iconSymbol = [[NSMutableArray alloc] init];
    {
        for (IconSymbolRecord *record in iconDict.allValues) {
            [iconSymbol addObject:[record buildWebIconObject]];
        }
    }
    [renderingSchemeObject setObject:iconSymbol forKey:KEY_ICON_SYMBOL];
    
    
    return @{KEY_RENDERING_SCHEME: renderingSchemeObject};
}

@end
