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

#import "TYBuilding.h"
#import "TYCity.h"
#import "MD5Utils.h"

@implementation TYMapFileManager

+ (NSString *)getCityJsonPath
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *fileName = FILE_CITIES;
    return [mapRootDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getBuildingJsonPath:(NSString *)cityID
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:cityID];
    NSString *fileName = [NSString stringWithFormat:FILE_BUILDINGS, cityID];
    return [cityDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getMapInfoJsonPath:(NSString *)cityID buildingID:(NSString *)buildingID
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_MAPINFO, buildingID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getMapDataPath:(TYMapInfo *)info
{
    NSString *buildingDir = [TYMapFileManager getBuildingDir:info];
    NSString *fileName = [NSString stringWithFormat:FILE_MAP_DATA_PATH, info.mapID];
    if ([TYMapEnvironment useEncryption]) {
        fileName = [MD5Utils md5:fileName];
        fileName = [NSString stringWithFormat:@"%@.tymap", fileName];
    }
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

+ (NSString *)getRenderingScheme:(TYBuilding *)building
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_RENDERING_SCHEME, building.buildingID];
    
    NSString *renderingPath = [buildingDir stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:renderingPath isDirectory:nil]) {
        return renderingPath;
    } else {
        return [TYMapFileManager getDefaultRenderingScheme];
    }
}

+ (NSString *)getDefaultRenderingScheme
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    return [mapRootDir stringByAppendingPathComponent:FILE_DEFAULT_RENDERING_SCHEME];
}

+ (NSString *)getPOIDBPath:(TYBuilding *)building
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_POI_DB, building.buildingID];
    
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getPrimitiveDBPath:(TYBuilding *)building
{
    NSString *mapRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_PRIMITIVE_DB, building.buildingID];
    
    return [buildingDir stringByAppendingPathComponent:fileName];
}

@end
