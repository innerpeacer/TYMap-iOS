//
//  AddCityBuildingMapInfoVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "AddCityBuildingMapInfoVC.h"
#import <TYMapData/TYMapData.h>

#import "TYCityManager.h"
#import "TYBuildingManager.h"
#import "TYUserDefaults.h"
#import "TYMapInfo.h"
#import "MapLicenseGenerator.h"
#import "TYUserManager.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "TYSyncMapDataDBAdapter.h"

#import "TYCBMUploader.h"
#import "TYCBMDownloader.h"

@interface AddCityBuildingMapInfoVC() <TYCBMUploaderDelegate, TYCBMDownloaderDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSArray *allMapInfos;
    
    NSString *hostName;
    
    
    TYCBMUploader *dataUploader;
    TYCBMDownloader *dataDownloader;
}

- (IBAction)uploadCurrentBuildingData:(id)sender;
- (IBAction)getCurrentBuildingData:(id)sender;
@end

@implementation AddCityBuildingMapInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];
    
    hostName = HOST_NAME;
    
    dataUploader = [[TYCBMUploader alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID]];
    dataUploader.delegate = self;
    
    dataDownloader = [[TYCBMDownloader alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    dataDownloader.delegate = self;
    
    NSLog(@"%@", currentCity);
    NSLog(@"%@", currentBuilding);
    NSLog(@"%@", allMapInfos);
}

- (void)TYCBMUploader:(TYCBMUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self addToLog:description];
}

- (void)TYCBMUploader:(TYCBMUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataUploaderDidFailedUploading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataDownloaderDidFailedDownloading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    if ([api isEqualToString:TY_API_GET_TARGET_CITY]) {
        [self addToLog:[NSString stringWithFormat:@"Records: %d", records]];
        [self addToLog:[NSString stringWithFormat:@"Get %d Cities From Server", (int)resultArray.count]];
        NSMutableString *cityString = [NSMutableString string];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TYCity *c = obj;
            [cityString appendFormat:@"[%@] ", c.name];
        }];
        [self addToLog:cityString];
    }
    
    if ([api isEqualToString:TY_API_GET_TARGET_BUILDING]) {
        [self addToLog:[NSString stringWithFormat:@"Records: %d", records]];
        [self addToLog:[NSString stringWithFormat:@"Get %d Buildings From Server", (int)resultArray.count]];
        NSMutableString *buildingString = [NSMutableString string];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TYBuilding *b = obj;
            [buildingString appendFormat:@"[%@] ", b.name];
        }];
        [self addToLog:buildingString];
    }
    
    if ([api isEqualToString:TY_API_GET_TARGET_MAPINFO]) {
        [self addToLog:[NSString stringWithFormat:@"Records: %d", records]];
        [self addToLog:[NSString stringWithFormat:@"Get %d MapInfos From Server", (int)resultArray.count]];
        NSMutableString *mapInfoString = [NSMutableString string];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TYMapInfo *m = obj;
            [mapInfoString appendFormat:@"[%@] ", m.mapID];
        }];
        [self addToLog:mapInfoString];
    }
    
}

- (void)addCities
{
    [self addToLog:[NSString stringWithFormat:@"======= addCities:\n%@%@", hostName, TY_API_ADD_CITIES]];
    [dataUploader addCities:@[currentCity]];
}

- (void)addBuildings
{
    [self addToLog:[NSString stringWithFormat:@"======= addBuildigs:\n%@%@", hostName, TY_API_ADD_BUILDINGS]];
    [dataUploader addBuildings:@[currentBuilding]];
}

- (void)addMapInfos
{
    [self addToLog:[NSString stringWithFormat:@"======= addMapInfos:\n%@%@", hostName, TY_API_ADD_MAPINFOS]];
    [dataUploader addMapInfos:allMapInfos];
}

- (void)getCities
{
    [self addToLog:[NSString stringWithFormat:@"======= getCities:\n%@%@", hostName, TY_API_GET_TARGET_CITY]];
    [dataDownloader getCity:currentCity.cityID];
}

- (void)getBuildings
{
    [self addToLog:[NSString stringWithFormat:@"======= getBuildings:\n%@%@", hostName, TY_API_GET_TARGET_BUILDING]];
    [dataDownloader getBuildings];
}

- (void)getMapInfos
{
    [self addToLog:[NSString stringWithFormat:@"======= getMapInfos:\n%@%@", hostName, TY_API_GET_TARGET_MAPINFO]];
    [dataDownloader getMapInfos];
}


- (IBAction)uploadCurrentBuildingData:(id)sender {
    NSLog(@"uploadCurrentBuildingData");
    [self addCities];
    [self addBuildings];
    [self addMapInfos];
}

- (IBAction)getCurrentBuildingData:(id)sender {
    NSLog(@"getCurrentBuildingData");
    [self getCities];
    [self getBuildings];
    [self getMapInfos];
}
@end
