//
//  GenerateWebMapFileVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/2.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "GenerateWebMapFileVC.h"
#import <TYMapData/TYMapData.h>
#import "TYUserDefaults.h"
#import "TYMapInfo.h"

#import "IPMapDBAdapter.h"
#import "IPMapFileManager.h"
#import "TYMapEnviroment.h"
#import "IPMapFeatureData.h"
#import "TYRenderingScheme.h"
#import "WebMapFields.h"
#import "WebMapObjectBuilder.h"
#import "WebSymbolDBAdpater.h"

#define WEB_MAP_ROOT @"WebMap"

@interface GenerateWebMapFileVC()
{
    NSFileManager *fileManager;
    NSString *webMapFileDir;
    
    TYCity *currentCity;
    TYBuilding *currentBuilding;
}

@end

@implementation GenerateWebMapFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    fileManager = [NSFileManager defaultManager];
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createWebMapFileForCurrentBuilding) object:nil];
    [thread start];
    
}

- (void)createWebMapFileForCurrentBuilding
{
    [self checkDirectory];
    [self generateCityJson];
    [self generateBuildingJson:currentCity];
    [self generateMapInfoJson:currentBuilding];
    [self generateRenderingScheme:currentBuilding];
    [self generateWebMapDataFile:currentBuilding];
}


- (void)checkDirectory
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    webMapFileDir = [documentDirectory stringByAppendingPathComponent:WEB_MAP_ROOT];
    NSString *log = @"================================================";
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
//    [self checkWebMapRootDirectory];
//    [self checkCityDirectory:currentCity];
    [self checkBuildingDirectory:currentBuilding];
}


- (void)generateWebMapDataFile:(TYBuilding *)building
{
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    
    NSMutableDictionary *mapDataJsonDict = [[NSMutableDictionary alloc] init];
    IPMapFeatureData *featureData = [[IPMapFeatureData alloc] initWithBuilding:building];
    
    NSString *log = @"================================================";
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
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
        
        log = [NSString stringWithFormat:@"Create File: \t%@", mapDataJsonPath.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    }
}

- (void)generateRenderingScheme:(TYBuilding *)building
{
    NSError *error = nil;
    
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *renderingSchemeFile = [NSString stringWithFormat:FILE_RENDERING_SCHEME, building.buildingID];
    NSString *renderingSchemeJsonPath = [buildingDir stringByAppendingPathComponent:renderingSchemeFile];
    NSString *log;
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
 
    log = [NSString stringWithFormat:@"Create File: \t%@", renderingSchemeJsonPath.lastPathComponent];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
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


- (void)generateBuildingJson:(TYCity *)city
{
    NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:city.cityID];
    IPMapDBAdapter *db = [[IPMapDBAdapter alloc] initWithPath:[IPMapFileManager getMapDBPath]];
    [db open];
    NSArray *allBuildingArray = [db getAllBuildings:city];
    
    NSMutableDictionary *buildingJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *buildingJsonArray = [[NSMutableArray alloc] init];
    for (TYBuilding *building in allBuildingArray) {
        [buildingJsonArray addObject:[WebMapObjectBuilder generateWebBuildingObject:building]];
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

- (void)generateCityJson
{
    IPMapDBAdapter *db = [[IPMapDBAdapter alloc] initWithPath:[IPMapFileManager getMapDBPath]];
    [db open];
    NSArray *allCityArray = [db getAllCities];
    
    NSMutableDictionary *cityJsonDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *cityJsonArray = [[NSMutableArray alloc] init];
    for (TYCity *city in allCityArray) {
        [cityJsonArray addObject:[WebMapObjectBuilder generateWebCityObject:city]];
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

    NSString *log = @"================================================\n";
    log = [NSString stringWithFormat:@"%@Create File: \t%@", log, cityJsonPath.lastPathComponent];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];

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
