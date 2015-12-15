//
//  TYMapFileManager.m
//  MapProject
//
//  Created by innerpeacer on 15/4/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYMapFileManager.h"
#import "TYMapEnviroment.h"

#import "TYMapFileContants.h"

#import <TYMapData/TYMapData.h>

#import "MD5Utils.h"

@implementation TYMapFileManager

+ (NSString *)getMapDBPath
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *fileName = FILE_MAP_DATABASE;
    return [mapRootDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getMapDataDBPath:(TYBuilding *)building
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_MAP_DB_PATH, building.buildingID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getCityDir:(TYMapInfo *)info
{
    return [[TYMapEnvironment getRootDirectoryForMapFiles] stringByAppendingPathComponent:info.cityID];
}

+ (NSString *)getBuildingDir:(TYMapInfo *)info
{
    return [[[TYMapEnvironment getRootDirectoryForMapFiles] stringByAppendingPathComponent:info.cityID] stringByAppendingPathComponent:info.buildingID];
}

+ (NSString *)getLandmarkJsonPath:(TYMapInfo *)info
{
    NSString *buildingDir = [TYMapFileManager getBuildingDir:info];
    NSString *fileName = [NSString stringWithFormat:FILE_LAYER_PATH_LANDMARK, info.mapID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getBrandJsonPath:(TYBuilding *)building
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    
    NSString *fileName = [NSString stringWithFormat:FILE_BRANDS, building.buildingID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getPOIDBPath:(TYBuilding *)building
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_POI_DB, building.buildingID];
    
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getSymbolDBPath:(TYBuilding *)building
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_SYMBOL_DB_PATH, building.buildingID];
    
    return [buildingDir stringByAppendingPathComponent:fileName];
}

@end
