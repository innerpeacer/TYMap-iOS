//
//  NPMapFileManager.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPMapFileManager.h"
#import "NPMapEnviroment.h"

#define FILE_CITIES @"Cities.json"

#define FILE_BUILDINGS @"Buildings_City_%@.json"

#define FILE_MAPINFO @"MapInfo_Building_%@.json"

#define FILE_RENDERING_SCHEME @"%@_RenderingScheme.json"
#define FILE_DEFAULT_RENDERING_SCHEME @"RenderingScheme.json"

#define FILE_POI_DB @"%@_POI.db"
#define FILE_PRIMITIVE_DB @"%@_Primitive.db"
#define FILE_LAYER_PATH_FLOOR @"%@_FLOOR.json"
#define FILE_LAYER_PATH_ROOM @"%@_ROOM.json"
#define FILE_LAYER_PATH_ASSET @"%@_ASSET.json"
#define FILE_LAYER_PATH_FACILITY @"%@_FACILITY.json"
#define FILE_LAYER_PATH_LABEL @"%@_LABEL.json"

#import "NPBuilding.h"
#import "NPCity.h"

@implementation NPMapFileManager

+ (NSString *)getCityJsonPath
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *fileName = FILE_CITIES;
    return [mapRootDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getBuildingJsonPath:(NSString *)cityID
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:cityID];
    NSString *fileName = [NSString stringWithFormat:FILE_BUILDINGS, cityID];
    return [cityDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getMapInfoJsonPath:(NSString *)cityID buildingID:(NSString *)buildingID
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_MAPINFO, buildingID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getFloorLayerPath:(NPMapInfo *)info
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:info.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:info.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_LAYER_PATH_FLOOR, info.mapID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getRoomLayerPath:(NPMapInfo *)info
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:info.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:info.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_LAYER_PATH_ROOM, info.mapID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getAssetLayerPath:(NPMapInfo *)info
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:info.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:info.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_LAYER_PATH_ASSET, info.mapID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getFacilityLayerPath:(NPMapInfo *)info
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:info.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:info.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_LAYER_PATH_FACILITY, info.mapID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getLabelLayerPath:(NPMapInfo *)info
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:info.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:info.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_LAYER_PATH_LABEL, info.mapID];
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getRenderingScheme:(NPBuilding *)building
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_RENDERING_SCHEME, building.buildingID];
    
    NSString *renderingPath = [buildingDir stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:renderingPath isDirectory:nil]) {
        return renderingPath;
    } else {
        return [NPMapFileManager getDefaultRenderingScheme];
    }
}

+ (NSString *)getDefaultRenderingScheme
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    return [mapRootDir stringByAppendingPathComponent:FILE_DEFAULT_RENDERING_SCHEME];
}

+ (NSString *)getPOIDBPath:(NPBuilding *)building
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_POI_DB, building.buildingID];
    
    return [buildingDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getPrimitiveDBPath:(NPBuilding *)building
{
    NSString *mapRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *cityDir = [mapRootDir stringByAppendingPathComponent:building.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:building.buildingID];
    NSString *fileName = [NSString stringWithFormat:FILE_PRIMITIVE_DB, building.buildingID];
    
    return [buildingDir stringByAppendingPathComponent:fileName];
}

@end
