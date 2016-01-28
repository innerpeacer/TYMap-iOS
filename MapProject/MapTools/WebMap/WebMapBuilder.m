//
//  WebMapBuilder.m
//  MapProject
//
//  Created by innerpeacer on 16/1/27.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "WebMapBuilder.h"
#import "WebMapObjectBuilder.h"
#import "WebMapFields.h"
#import "WebSymbolDBAdpater.h"
#import "IPMapFileManager.h"
#import "IPMapFeatureData.h"

@interface WebMapBuilder()
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSString *webMapFileDir;
    NSFileManager *fileManager;
}

@end

@implementation WebMapBuilder

- (id)initWithCity:(TYCity *)city Building:(TYBuilding *)building WithWebRoot:(NSString *)root
{
    self = [super init];
    if (self) {
        currentCity = city;
        currentBuilding = building;
        webMapFileDir = root;
        fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)buildWebMap
{
    [self checkDirectory];
}

- (void)checkDirectory
{
    NSString *process = @"================================================";
    [self notifyProcessUpdate:process];
    [self checkBuildingDirectory:currentBuilding];
    [self generateCityJson:@[currentCity]];
    [self generateBuildingJsonWithCity:currentCity Buildings:@[currentBuilding]];
    [self generateMapInfoJson:currentBuilding];
    [self generateRenderingScheme:currentBuilding];
    [self generateWebMapDataFile:currentBuilding];
}

- (void)checkBuildingDirectory:(TYBuilding *)building
{
    NSString *process;
    NSError *error = nil;
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    if (![fileManager fileExistsAtPath:buildingDir]) {
        [fileManager createDirectoryAtPath:buildingDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        process = [NSString stringWithFormat:@"Create Directory: \t%@", buildingDir.lastPathComponent];
        [self notifyProcessUpdate:process];
        
    } else {
        process = [NSString stringWithFormat:@"Directory Exist: \t%@", buildingDir.lastPathComponent];
        [self notifyProcessUpdate:process];
    }
}

+ (void)generateCityJson:(NSArray *)cityArray WithRoot:(NSString *)root
{
    NSMutableDictionary *cityJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *cityJsonArray = [[NSMutableArray alloc] init];
    for (TYCity *city in cityArray) {
        [cityJsonArray addObject:[WebMapObjectBuilder generateWebCityObject:city]];
    }
    [cityJsonDict setObject:cityJsonArray forKey:KEY_WEB_CITIES];
    
    NSString *cityJsonPath = [root stringByAppendingPathComponent:@"Cities.json"];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cityJsonDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [jsonData writeToFile:cityJsonPath atomically:YES];
}

- (void)generateCityJson:(NSArray *)cityArray
{
    [WebMapBuilder generateCityJson:cityArray WithRoot:webMapFileDir];
    
    NSString *cityJsonPath = [webMapFileDir stringByAppendingPathComponent:@"Cities.json"];
    NSString *process = @"================================================\n";
    process = [NSString stringWithFormat:@"%@Create File: \t%@", process, cityJsonPath.lastPathComponent];
    [self notifyProcessUpdate:process];
}

+ (void)generateBuildingJsonWithCity:(TYCity *)city Buildings:(NSArray *)buildingArray WithRoot:(NSString *)root
{
    NSMutableDictionary *buildingJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *buildingJsonArray = [[NSMutableArray alloc] init];
    for (TYBuilding *building in buildingArray) {
        [buildingJsonArray addObject:[WebMapObjectBuilder generateWebBuildingObject:building]];
    }
    [buildingJsonDict setObject:buildingJsonArray forKey:KEY_WEB_BUILDINGS];
    
    NSString *cityDir = [root stringByAppendingPathComponent:city.cityID];
    NSString *buildingJsonPath = [cityDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Buildings_City_%@.json", city.cityID]];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:buildingJsonDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [jsonData writeToFile:buildingJsonPath atomically:YES];
}

- (void)generateBuildingJsonWithCity:(TYCity *)city Buildings:(NSArray *)buildingArray
{
    [WebMapBuilder generateBuildingJsonWithCity:city Buildings:buildingArray WithRoot:webMapFileDir];
    
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:city.cityID];
    NSString *buildingJsonPath = [cityDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Buildings_City_%@.json", city.cityID]];
    NSString *process;
    process = [NSString stringWithFormat:@"Create File: \t%@", buildingJsonPath.lastPathComponent];
    [self notifyProcessUpdate:process];
}

- (void)generateMapInfoJson:(TYBuilding *)building
{
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSMutableDictionary *mapInfoJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *mapInfoJsonArray = [[NSMutableArray alloc] init];
    NSArray *allMapInfos = [TYMapInfo parseAllMapInfo:building];
    for (TYMapInfo *mapInfo in allMapInfos) {
        [mapInfoJsonArray addObject:[WebMapObjectBuilder generateWebMapInfoObject:mapInfo]];
    }
    [mapInfoJsonDict setObject:mapInfoJsonArray forKey:KEY_WEB_MAPINFOS];
    
    NSString *mapInfoJsonPath = [buildingDir stringByAppendingPathComponent:[NSString stringWithFormat:@"MapInfo_Building_%@.json", building.buildingID]];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mapInfoJsonDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [jsonData writeToFile:mapInfoJsonPath atomically:YES];
    
    NSString *process;
    process = [NSString stringWithFormat:@"Create File: \t%@", mapInfoJsonPath.lastPathComponent];
    [self notifyProcessUpdate:process];
}

- (void)generateRenderingScheme:(TYBuilding *)building
{
    NSError *error = nil;
    
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *renderingSchemeFile = [NSString stringWithFormat:FILE_WEB_RENDERING_SCHEME, building.buildingID];
    NSString *renderingSchemeJsonPath = [buildingDir stringByAppendingPathComponent:renderingSchemeFile];
    NSString *symbolDBPath = [IPMapFileManager getSymbolDBPath:building];
    WebSymbolDBAdpater *db = [[WebSymbolDBAdpater alloc] initWithPath:symbolDBPath];
    [db open];
    NSDictionary *fillDict = [db readFillSymbols];
    NSDictionary *iconDict = [db readIconSymbols];
    [db close];
    
    NSDictionary *renderingSchemeObject = [WebMapObjectBuilder generateWebRenderingSchemeObjectWithFill:fillDict Icon:iconDict];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:renderingSchemeObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [jsonData writeToFile:renderingSchemeJsonPath atomically:YES];
    
    NSString *process;
    process = [NSString stringWithFormat:@"Create File: \t%@", renderingSchemeJsonPath.lastPathComponent];
    [self notifyProcessUpdate:process];
}

- (void)generateWebMapDataFile:(TYBuilding *)building
{
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    
    NSMutableDictionary *mapDataJsonDict = [[NSMutableDictionary alloc] init];
    IPMapFeatureData *featureData = [[IPMapFeatureData alloc] initWithBuilding:building];
    
    NSString *process = @"================================================";
    [self notifyProcessUpdate:process];
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
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mapDataJsonDict options:kNilOptions error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [jsonData writeToFile:mapDataJsonPath atomically:YES];
        
        process = [NSString stringWithFormat:@"Create File: \t%@", mapDataJsonPath.lastPathComponent];
        [self notifyProcessUpdate:process];
    }
}


- (void)notifyProcessUpdate:(NSString *)process
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(WebMapBuilder:processUpdated:)]) {
        [self.delegate WebMapBuilder:self processUpdated:process];
    }
}

@end
