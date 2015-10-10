//
//  ViewController.m
//  TYMapEncryption
//
//  Created by innerpeacer on 15/7/23.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapEncryptionVC.h"

#import "TYEncryption.h"
#include "MD5.hpp"
#import "TYMapEnviroment.h"
#import "TYUserDefaults.h"

#import "TYMapInfo.h"
#import "TYMapFileContants.h"

@interface MapEncryptionVC ()
{
    //    NSArray *layerArray;
    
    TYBuilding *currentBuilding;
    TYCity *currentCity;
    NSArray *allMapInfos;
    
    NSString *sourceBuildingDir;
    NSString *targetBuildingDir;
}

@end

@implementation MapEncryptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    layerArray = @[@"FLOOR", @"ROOM", @"ASSET", @"FACILITY", @"LABEL"];
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];
    
    self.title = @"Map Encryption";
    
    [self addToLog:@"Begin Encryption"];
    
    [self prepareDirectory];
    
    [self encryptMapFiles];
    
    [self addToLog:@"End Encryption"];
}

- (void)encryptMapFiles
{
    NSError *error = nil;
    
    NSString *renderingSchemeFile = [NSString stringWithFormat:FILE_RENDERING_SCHEME, currentBuilding.buildingID];
    NSString *sourceRenderSchemeFile = [sourceBuildingDir stringByAppendingPathComponent:renderingSchemeFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourceRenderSchemeFile isDirectory:nil]) {
        [[NSFileManager defaultManager] copyItemAtPath:sourceRenderSchemeFile toPath:[targetBuildingDir stringByAppendingPathComponent:renderingSchemeFile] error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
        }
        
        [self addToLog:[NSString stringWithFormat:@"\tCopy RenderingScheme: %@", renderingSchemeFile]];
    }
    
    NSString *mapInfoFile = [NSString stringWithFormat:FILE_MAPINFO, currentBuilding.buildingID];
    [[NSFileManager defaultManager] copyItemAtPath:[sourceBuildingDir stringByAppendingPathComponent:mapInfoFile] toPath:[targetBuildingDir stringByAppendingPathComponent:mapInfoFile] error:&error];
    if (error) {
        NSLog(@"%@", [error description]);
    }
    [self addToLog:[NSString stringWithFormat:@"\tCopy MapInfo: %@", mapInfoFile]];
    
    NSString *poiDBFile = [NSString stringWithFormat:FILE_POI_DB, currentBuilding.buildingID];
    NSString *sourcePoiDBFile = [sourceBuildingDir stringByAppendingPathComponent:poiDBFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePoiDBFile isDirectory:nil]) {
        [[NSFileManager defaultManager] copyItemAtPath:sourcePoiDBFile toPath:[targetBuildingDir stringByAppendingPathComponent:poiDBFile] error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
        }
        [self addToLog:[NSString stringWithFormat:@"\tCopy POI database: %@", poiDBFile]];
    }

    
    NSString *routeDBFile = [NSString stringWithFormat:FILE_ROUTE_DB, currentBuilding.buildingID];
    NSString *sourceRouteDBFile = [sourceBuildingDir stringByAppendingPathComponent:routeDBFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourceRouteDBFile isDirectory:nil]) {
        [[NSFileManager defaultManager] copyItemAtPath:sourceRouteDBFile toPath:[targetBuildingDir stringByAppendingPathComponent:routeDBFile] error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
        }
        [self addToLog:[NSString stringWithFormat:@"\tCopy Route database: %@", routeDBFile]];
    }

    
    NSLog(@"MapInfo: %d", (int)allMapInfos.count);
    MD5 fileMd5;
    
    for(TYMapInfo *info in allMapInfos) {
        NSString *fileName = [NSString stringWithFormat:FILE_MAP_DATA_PATH, info.mapID];
        NSString *originalFile = [sourceBuildingDir stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:originalFile]) {
            continue;
        }
        
        fileMd5.reset();
        fileMd5.update([fileName UTF8String]);
        NSString *encryptedFileName = [NSString stringWithUTF8String:fileMd5.toString().c_str()];
        encryptedFileName = [NSString stringWithFormat:@"%@.tymap", encryptedFileName];
        
        NSString *encryptedFile = [targetBuildingDir stringByAppendingPathComponent:encryptedFileName];
        
        [TYEncryption encryptFile:originalFile toFile:encryptedFile];
        
        [self addToLog:[NSString stringWithFormat:@"\tEncrypt: %@ ==> %@", fileName, encryptedFileName]];
        
    }
    
}

- (void)prepareDirectory
{
    NSLog(@"encryptMapFiles");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *targetRootDir = [documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ENCRPTION_ROOT];
    NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:DEFAULT_MAP_ROOT ofType:nil];
    
    NSString *cityDir = [targetRootDir stringByAppendingPathComponent:currentBuilding.cityID];
    if (![fileManager fileExistsAtPath:cityDir isDirectory:nil]) {
        [fileManager createDirectoryAtPath:cityDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    targetBuildingDir = [cityDir stringByAppendingPathComponent:currentBuilding.buildingID];
    sourceBuildingDir = [[sourceRootDir stringByAppendingPathComponent:currentBuilding.cityID] stringByAppendingPathComponent:currentBuilding.buildingID];
    
    if (![fileManager fileExistsAtPath:targetBuildingDir isDirectory:nil]) {
        [fileManager createDirectoryAtPath:targetBuildingDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


@end
