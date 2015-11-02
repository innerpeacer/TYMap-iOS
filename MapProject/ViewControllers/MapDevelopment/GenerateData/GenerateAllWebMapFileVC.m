//
//  GenerateAllWebMapFileVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/2.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "GenerateAllWebMapFileVC.h"
#import <TYMapData/TYMapData.h>
#import "TYUserDefaults.h"
#import "TYMapInfo.h"

#import "TYMapDBAdapter.h"
#import "TYMapFileManager.h"
#import "TYMapEnviroment.h"
#import "TYMapFeatureData.h"

#define WEB_MAP_ROOT @"WebMap"

@interface GenerateAllWebMapFileVC()
{
    NSFileManager *fileManager;
    NSString *webMapFileDir;
    
    TYCity *currentCity;
    TYBuilding *currentBuilding;
}

@end

@implementation GenerateAllWebMapFileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fileManager = [NSFileManager defaultManager];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createAllWebMapFiles) object:nil];
    [thread start];
}

//- (void)checkDirectory
//{
//    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    webMapFileDir = [documentDirectory stringByAppendingPathComponent:WEB_MAP_ROOT];
//    NSString *log = @"================================================";
//    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
//    [self checkWebMapRootDirectory];
//    [self checkCityDirectory:currentCity];
//    [self checkBuildingDirectory:currentBuilding];
//}

- (NSString *)logTitleForCity:(TYCity *)city
{
    NSString *title = @"================================================";
    int titleLength = (int)title.length;
    int length = (int)city.name.length * 2 + 4;
    
    NSMutableString *result = [NSMutableString string];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    [result appendString:@"  "];
    [result appendString:city.name];
    [result appendString:@"  "];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    return result;
}

- (NSString *)logTitleForBuilding:(TYBuilding *)building
{
    NSString *title = @"================================================";
    int titleLength = (int)title.length;
    int length = (int)building.name.length * 2 + 4;
    
    NSMutableString *result = [NSMutableString string];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    [result appendString:@"  "];
    [result appendString:building.name];
    [result appendString:@"  "];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    return result;
}

- (void)createAllWebMapFiles
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    webMapFileDir = [documentDirectory stringByAppendingPathComponent:WEB_MAP_ROOT];
    NSLog(@"%@", webMapFileDir);
    NSString *log = @"================================================";
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    [self checkWebMapRootDirectory];
    [self generateCityJson];

    TYMapDBAdapter *db = [[TYMapDBAdapter alloc] initWithPath:[TYMapFileManager getMapDBPath]];
    [db open];
    NSArray *allCityArray = [db getAllCities];
    for (TYCity *city in allCityArray) {
//        log = @"================================================";
//        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
//        [self performSelectorOnMainThread:@selector(updateUI:) withObject:[NSString stringWithFormat:@"\t%@", city.name] waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:[self logTitleForCity:city] waitUntilDone:YES];

        [self checkCityDirectory:city];
        [self generateBuildingJson:city];
        NSArray *allBuildings = [db getAllBuildings:city];
        for (TYBuilding *building in allBuildings) {
            log = @"================================================";
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:[NSString stringWithFormat:@"\t%@", building.name] waitUntilDone:YES];

            [self checkBuildingDirectory:building];
            [self generateMapInfoJson:building];
            [self generateRenderingScheme:building];
            [self generateWebMapDataFile:building];
        }
    }
    
    [db close];

}


#define FILE_WEB_MAP_DATA @"%@.data"
- (void)generateWebMapDataFile:(TYBuilding *)building
{
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    
    NSMutableDictionary *mapDataJsonDict = [[NSMutableDictionary alloc] init];
    TYMapFeatureData *featureData = [[TYMapFeatureData alloc] initWithBuilding:building];
    
    NSString *log;
    NSArray *allMapInfos = [TYMapInfo parseAllMapInfo:building];
    for (TYMapInfo *info in allMapInfos) {
        NSDictionary *mapDataDict = [featureData getAllMapDataOnFloor:info.floorNumber];
        NSString *mapDataJsonPath = [buildingDir stringByAppendingPathComponent:[NSString stringWithFormat:FILE_WEB_MAP_DATA, info.mapID]];
        NSError *error = nil;
        
        for (NSString *key in mapDataDict.allKeys) {
            AGSFeatureSet *set = [mapDataDict objectForKey:key];
            NSDictionary *setDict = [set encodeToJSON];
            [mapDataJsonDict setObject:setDict forKey:key];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mapDataJsonDict options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [jsonData writeToFile:mapDataJsonPath atomically:YES];
        
        log = [NSString stringWithFormat:@"Create File: \t%@", mapDataJsonPath.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    }
}

#define FILE_RENDERING_SCHEME @"%@_RenderingScheme.json"
- (void)generateRenderingScheme:(TYBuilding *)building
{
    NSError *error = nil;
    
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *renderingSchemeFile = [NSString stringWithFormat:FILE_RENDERING_SCHEME, building.buildingID];
    NSString *sourceBuildingDir = [TYMapEnvironment getBuildingDirectory:building];
    NSString *sourceRenderSchemePath = [sourceBuildingDir stringByAppendingPathComponent:renderingSchemeFile];
    
    NSString *renderingSchemeJsonPath = [buildingDir stringByAppendingPathComponent:renderingSchemeFile];
    NSString *log;
    if (![fileManager fileExistsAtPath:renderingSchemeJsonPath isDirectory:nil]) {
        [fileManager copyItemAtPath:sourceRenderSchemePath toPath:renderingSchemeJsonPath error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        log = [NSString stringWithFormat:@"Copy File: \t%@", renderingSchemeJsonPath.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    } else {
        log = [NSString stringWithFormat:@"File Exist: \t%@", renderingSchemeJsonPath.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    }
}


#define KEY_MAPINFOS @"MapInfo"
#define KEY_MAPINFO_CITYID @"cityID"
#define KEY_MAPINFO_BUILDINGID @"buildingID"
#define KEY_MAPINFO_MAPID @"mapID"
#define KEY_MAPINFO_FLOOR @"floorName"
#define KEY_MAPINFO_FLOOR_INDEX @"floorNumber"
#define KEY_MAPINFO_SIZEX @"size_x"
#define KEY_MAPINFO_SIZEY @"size_y"
#define KEY_MAPINFO_XMIN @"xmin"
#define KEY_MAPINFO_XMAX @"xmax"
#define KEY_MAPINFO_YMIN @"ymin"
#define KEY_MAPINFO_YMAX @"ymax"
- (void)generateMapInfoJson:(TYBuilding *)building
{
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSMutableDictionary *mapInfoJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *mapInfoJsonArray = [[NSMutableArray alloc] init];
    NSArray *allMapInfos = [TYMapInfo parseAllMapInfo:building];
    for (TYMapInfo *mapInfo in allMapInfos) {
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
        [mapInfoJsonArray addObject:mapInfoObject];
    }
    [mapInfoJsonDict setObject:mapInfoJsonArray forKey:KEY_MAPINFOS];
    
    NSString *mapInfoJsonPath = [buildingDir stringByAppendingPathComponent:[NSString stringWithFormat:@"MapInfo_Building_%@.json", building.buildingID]];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mapInfoJsonDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [jsonData writeToFile:mapInfoJsonPath atomically:YES];
    
    NSString *log;
    log = [NSString stringWithFormat:@"Create File: \t%@", mapInfoJsonPath.lastPathComponent];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
}

#define KEY_BUILDINGS @"Buildings"
#define KEY_BUILDING_CITY_ID @"cityID"
#define KEY_BUILDING_ID @"id"
#define KEY_BUILDING_NAME @"name"
#define KEY_BUILDING_LONGITUDE @"longitude"
#define KEY_BUILDING_LATITUDE @"latitude"
#define KEY_BUILDING_ADDRESS @"address"
#define KEY_BUILDING_INIT_ANGLE @"initAngle"
#define KEY_BUILDING_ROUTE_URL @"routeURL"
#define KEY_BUILDING_OFFSET_X @"offsetX"
#define KEY_BUILDING_OFFSET_Y @"offsetY"
#define KEY_BUILDING_STATUS @"status"
- (void)generateBuildingJson:(TYCity *)city
{
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:city.cityID];
    TYMapDBAdapter *db = [[TYMapDBAdapter alloc] initWithPath:[TYMapFileManager getMapDBPath]];
    [db open];
    NSArray *allBuildingArray = [db getAllBuildings:city];
    
    NSMutableDictionary *buildingJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *buildingJsonArray = [[NSMutableArray alloc] init];
    for (TYBuilding *building in allBuildingArray) {
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
        [buildingJsonArray addObject:buildingObject];
    }
    [buildingJsonDict setObject:buildingJsonArray forKey:KEY_BUILDINGS];
    [db close];
    
    NSString *buildingJsonPath = [cityDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Buildings_City_%@.json", city.cityID]];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:buildingJsonDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [jsonData writeToFile:buildingJsonPath atomically:YES];
    
    NSString *log;
    log = [NSString stringWithFormat:@"Create File: \t%@", buildingJsonPath.lastPathComponent];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
}

#define KEY_CITIES @"Cities"
#define KEY_CITY_ID @"id"
#define KEY_CITY_NAME @"name"
#define KEY_CITY_SHORT_NAME @"sname"
#define KEY_CITY_LONGITUDE @"longitude"
#define KEY_CITY_LATITUDE @"latitude"
#define KEY_CITY_STATUS @"status"
- (void)generateCityJson
{
    TYMapDBAdapter *db = [[TYMapDBAdapter alloc] initWithPath:[TYMapFileManager getMapDBPath]];
    [db open];
    NSArray *allCityArray = [db getAllCities];
    
    NSMutableDictionary *cityJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *cityJsonArray = [[NSMutableArray alloc] init];
    for (TYCity *city in allCityArray) {
        NSMutableDictionary *cityObject = [[NSMutableDictionary alloc] init];
        [cityObject setObject:city.cityID forKey:KEY_CITY_ID];
        [cityObject setObject:city.name forKey:KEY_CITY_NAME];
        [cityObject setObject:city.sname forKey:KEY_CITY_SHORT_NAME];
        [cityObject setObject:@(city.longitude) forKey:KEY_CITY_LONGITUDE];
        [cityObject setObject:@(city.latitude) forKey:KEY_CITY_LATITUDE];
        [cityObject setObject:@(city.status) forKey:KEY_CITY_STATUS];
        [cityJsonArray addObject:cityObject];
    }
    [cityJsonDict setObject:cityJsonArray forKey:KEY_CITIES];
    [db close];
    
    NSString *cityJsonPath = [webMapFileDir stringByAppendingPathComponent:@"Cities.json"];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cityJsonDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [jsonData writeToFile:cityJsonPath atomically:YES];
    
    NSString *log;
    log = [NSString stringWithFormat:@"Create File: \t%@", cityJsonPath.lastPathComponent];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    
}

- (void)checkWebMapRootDirectory
{
    NSString *log;
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:webMapFileDir]) {
        [fileManager createDirectoryAtPath:webMapFileDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        log = [NSString stringWithFormat:@"Create Directory: \t%@", webMapFileDir.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    } else {
        log = [NSString stringWithFormat:@"Directory Exist: \t%@", webMapFileDir.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    }
}

- (void)checkCityDirectory:(TYCity *)city
{
    NSString *log;
    NSError *error = nil;
    NSString  *cityDir = [webMapFileDir stringByAppendingPathComponent:city.cityID];
    if (![fileManager fileExistsAtPath:cityDir]) {
        [fileManager createDirectoryAtPath:cityDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        log = [NSString stringWithFormat:@"Create Directory: \t%@", cityDir.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    } else {
        log = [NSString stringWithFormat:@"Directory Exist: \t%@", cityDir.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    }
}

- (void)checkBuildingDirectory:(TYBuilding *)building
{
    NSString *log;
    NSError *error = nil;
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    if (![fileManager fileExistsAtPath:buildingDir]) {
        //        NSLog(@"%@ not exist", buildingDir);
        [fileManager createDirectoryAtPath:buildingDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        log = [NSString stringWithFormat:@"Create Directory: \t%@", buildingDir.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    } else {
        log = [NSString stringWithFormat:@"Directory Exist: \t%@", buildingDir.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    }
}

- (void)updateUI:(NSString *)logString
{
    [self addToLog:logString];
}

@end
