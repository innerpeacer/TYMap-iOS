//
//  GenerateEncryptionSourceVC.m
//  MapProject
//
//  Created by innerpeacer on 15/8/31.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "GenerateEncryptionSourceVC.h"
#import "TYMapFileContants.h"
#import "TYUserDefaults.h"
#import "MD5.hpp"
#import "TYEncryption.h"

#import "TYMapInfo.h"
#import "TYCityManager.h"
#import "TYBuildingManager.h"

@interface GenerateEncryptionSourceVC()
{
    NSString *targetRootDir;
    NSString *sourceRootDir;
    
    NSString *currentIndentString;
}

@end


@implementation GenerateEncryptionSourceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"生成加密资源";
    
    [self addToLog:@"Begin Encryption"];
    [self prepareDirectory];
    [self encryptMapFiles];
    [self addToLog:@"End Encryption"];
}

- (void)encryptMapFiles
{
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    currentIndentString = @"";
    
    MD5 fileMd5;
    
    // Cities.json
    {
        NSString *cityJsonFile = [NSString stringWithFormat:@"Cities.json"];
        NSString *sourceCityJsonFile = [sourceRootDir stringByAppendingPathComponent:cityJsonFile];
        NSString *targetCityJsonFile = [targetRootDir stringByAppendingPathComponent:cityJsonFile];
        [fileManager copyItemAtPath:sourceCityJsonFile toPath:targetCityJsonFile error:&error];
        if (error) {
            [self addToLog:[NSString stringWithFormat:@"%@Error: Copy %@", currentIndentString, cityJsonFile]];
            error = nil;
        } else {
            [self addToLog:[NSString stringWithFormat:@"%@Copy City File: %@", currentIndentString, cityJsonFile]];
        }
    }
    
    // Default RenderingScheme
    {
        NSString *defaultRenderingSchemeFile = [NSString stringWithFormat:@"RenderingScheme.json"];
        NSString *sourceDefaultRenderingSchemeFile = [sourceRootDir stringByAppendingPathComponent:defaultRenderingSchemeFile];
        NSString *targetDefaultRenderingSchemeFile = [targetRootDir stringByAppendingPathComponent:defaultRenderingSchemeFile];
        [fileManager copyItemAtPath:sourceDefaultRenderingSchemeFile toPath:targetDefaultRenderingSchemeFile error:&error];
        if (error) {
            [self addToLog:[NSString stringWithFormat:@"%@Error: Copy %@", currentIndentString, defaultRenderingSchemeFile]];
            error = nil;
        } else {
            [self addToLog:[NSString stringWithFormat:@"%@Copy City File: %@", currentIndentString, defaultRenderingSchemeFile]];
        }
    }
    
    NSArray *allCities = [TYCityManager parseAllCities];
    for (TYCity *city in allCities) {
        currentIndentString = @"\t";
        
        NSString *cityID = city.cityID;
        NSString *sourceCityDir = [sourceRootDir stringByAppendingPathComponent:cityID];
        NSString *targetCityDir = [targetRootDir stringByAppendingPathComponent:cityID];
        
        [fileManager createDirectoryAtPath:targetCityDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        // Building_City json
        {
            NSString *buildingCityJsonFile = [NSString stringWithFormat:@"Buildings_City_%@.json", cityID];
            NSString *sourceBuildingCityJsonFile = [sourceCityDir stringByAppendingPathComponent:buildingCityJsonFile];
            NSString *targetBuildingCityJsonFile = [targetCityDir stringByAppendingPathComponent:buildingCityJsonFile];
            [fileManager copyItemAtPath:sourceBuildingCityJsonFile toPath:targetBuildingCityJsonFile error:&error];
            if (error) {
                [self addToLog:[NSString stringWithFormat:@"%@Error: Copy %@", currentIndentString, buildingCityJsonFile]];
                error = nil;
            } else {
                [self addToLog:[NSString stringWithFormat:@"%@Copy Building File: %@", currentIndentString, buildingCityJsonFile]];
            }
        }
        
        NSArray *allBuildings = [TYBuildingManager parseAllBuildings:city];
        for (TYBuilding *building in allBuildings) {
            currentIndentString = @"\t\t";
            NSString *buildingID = building.buildingID;
            NSString *sourceBuildingDir = [sourceCityDir stringByAppendingPathComponent:buildingID];
            NSString *targetBuildingDir = [targetCityDir stringByAppendingPathComponent:buildingID];
            [fileManager createDirectoryAtPath:targetBuildingDir withIntermediateDirectories:YES attributes:nil error:&error];
            
            // Building_Beacon.db
            {
                NSString *beaconDBFile = [NSString stringWithFormat:@"%@_Beacon.db", buildingID];
                NSString *sourceBeaconDBFile = [sourceBuildingDir stringByAppendingPathComponent:beaconDBFile];
                NSString *targetBeaconDBFile = [targetBuildingDir stringByAppendingPathComponent:beaconDBFile];
                if ([fileManager fileExistsAtPath:sourceBeaconDBFile]) {
                    [fileManager copyItemAtPath:sourceBeaconDBFile toPath:targetBeaconDBFile error:nil];
                    [self addToLog:[NSString stringWithFormat:@"%@Copy %@", currentIndentString, beaconDBFile]];
                } else {
                    [self addToLog:[NSString stringWithFormat:@"%@%@ not exist", currentIndentString, beaconDBFile]];
                }
            }
            
            // Building_POI.db
            {
                NSString *poiDBFile = [NSString stringWithFormat:@"%@_POI.db", buildingID];
                NSString *sourcePoiDBFile = [sourceBuildingDir stringByAppendingPathComponent:poiDBFile];
                NSString *targetPoiDBFile = [targetBuildingDir stringByAppendingPathComponent:poiDBFile];
                if ([fileManager fileExistsAtPath:sourcePoiDBFile]) {
                    [fileManager copyItemAtPath:sourcePoiDBFile toPath:targetPoiDBFile error:nil];
                    [self addToLog:[NSString stringWithFormat:@"%@Copy %@", currentIndentString, poiDBFile]];
                } else {
                    [self addToLog:[NSString stringWithFormat:@"%@%@ not exist", currentIndentString, poiDBFile]];
                }
            }
            
            // Building_RenderingScheme.json
            {
                NSString *renderingSchemeFile = [NSString stringWithFormat:@"%@_RenderingScheme.json", buildingID];
                NSString *sourceRenderingSchemeFile = [sourceBuildingDir stringByAppendingPathComponent:renderingSchemeFile];
                NSString *targetRenderingSchemeFile = [targetBuildingDir stringByAppendingPathComponent:renderingSchemeFile];
                if ([fileManager fileExistsAtPath:sourceRenderingSchemeFile]) {
                    [fileManager copyItemAtPath:sourceRenderingSchemeFile toPath:targetRenderingSchemeFile error:nil];
                    [self addToLog:[NSString stringWithFormat:@"%@Copy %@", currentIndentString, renderingSchemeFile]];
                } else {
                    [self addToLog:[NSString stringWithFormat:@"%@%@ not exist, use default", currentIndentString, renderingSchemeFile]];
                }
            }
            
            // MapInfo.json
            {
                NSString *mapInfoJsonFile = [NSString stringWithFormat:@"MapInfo_Building_%@.json", buildingID];
                NSString *sourceMapInfoJsonFile = [sourceBuildingDir stringByAppendingPathComponent:mapInfoJsonFile];
                NSString *targetMapInfoJsonFile = [targetBuildingDir stringByAppendingPathComponent:mapInfoJsonFile];
                if ([fileManager fileExistsAtPath:sourceMapInfoJsonFile]) {
                    [fileManager copyItemAtPath:sourceMapInfoJsonFile toPath:targetMapInfoJsonFile error:nil];
                    [self addToLog:[NSString stringWithFormat:@"%@Copy %@", currentIndentString, mapInfoJsonFile]];
                } else {
                    [self addToLog:[NSString stringWithFormat:@"%@%@ not exist", currentIndentString, mapInfoJsonFile]];
                }
            }
            
            NSArray *allMapInfo = [TYMapInfo parseAllMapInfo:building];
            for (TYMapInfo *info in allMapInfo) {
                
                NSString *mapDataFile = [NSString stringWithFormat:FILE_MAP_DATA_PATH, info.mapID];
                NSString *originalMapDataFile = [sourceBuildingDir stringByAppendingPathComponent:mapDataFile];
                
                fileMd5.reset();
                fileMd5.update([mapDataFile UTF8String]);
                NSString *encryptedFileName = [NSString stringWithUTF8String:fileMd5.toString().c_str()];
                encryptedFileName = [NSString stringWithFormat:@"%@.tymap", encryptedFileName];
                
                NSString *encryptedFile = [targetBuildingDir stringByAppendingPathComponent:encryptedFileName];
                [TYEncryption encryptFile:originalMapDataFile toFile:encryptedFile];
                
                [self addToLog:[NSString stringWithFormat:@"%@Encrypt: %@ ==> %@", currentIndentString, mapDataFile, encryptedFileName]];
            }
        }
        
    }
    
}

- (void)prepareDirectory
{
    NSLog(@"prepareDirectory");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    targetRootDir = [documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ENCRPTION_ROOT];
    sourceRootDir = [[NSBundle mainBundle] pathForResource:DEFAULT_MAP_ROOT ofType:nil];
    
    NSError *error;
    if ([fileManager fileExistsAtPath:targetRootDir]) {
        [fileManager removeItemAtPath:targetRootDir error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            error = nil;
        }
    }
    
    [fileManager createDirectoryAtPath:targetRootDir withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

@end
