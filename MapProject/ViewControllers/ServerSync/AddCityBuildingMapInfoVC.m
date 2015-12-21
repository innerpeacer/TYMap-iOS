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
#import "IPSyncMapDataDBAdapter.h"
#import "IPSyncMapSymbolDBAdapter.h"

#import "IPCBMUploader.h"
#import "IPCBMDownloader.h"

#import "IPMapFileManager.h"

@interface AddCityBuildingMapInfoVC() <IPCBMUploaderDelegate, IPCBMDownloaderDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSArray *allMapInfos;
    NSArray *allFillSymbols;
    NSArray *allIconSymbols;
    
    NSString *hostName;
    
    
    IPCBMUploader *dataUploader;
    IPCBMDownloader *dataDownloader;
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
    
    NSString *symbolPath = [IPMapFileManager getSymbolDBPath:currentBuilding];
    IPSyncMapSymbolDBAdapter *symbolDB = [[IPSyncMapSymbolDBAdapter alloc] initWithPath:symbolPath];
    [symbolDB open];
    allFillSymbols = [symbolDB getAllFillSymbols];
    allIconSymbols = [symbolDB getAllIconSymbols];
    [symbolDB close];
    
    hostName = HOST_NAME;
    
    dataUploader = [[IPCBMUploader alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID]];
    dataUploader.delegate = self;
    
    dataDownloader = [[IPCBMDownloader alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    dataDownloader.delegate = self;
    
    NSLog(@"%@", currentCity);
    NSLog(@"%@", currentBuilding);
    NSLog(@"%@", allMapInfos);
}

- (void)TYCBMUploader:(IPCBMUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    NSLog(@"%@", description);
    [self addToLog:description];
}

- (void)TYCBMUploader:(IPCBMUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataUploaderDidFailedUploading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)TYCBMDownloader:(IPCBMDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataDownloaderDidFailedDownloading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)TYCBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
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

- (void)TYCBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingSymbolsWithApi:(NSString *)api WithFillSymbols:(NSArray *)fillArray WithIconSymbols:(NSArray *)iconArray
{
    [self addToLog:[NSString stringWithFormat:@"Records: %d", (int)(fillArray.count + iconArray.count)]];
    [self addToLog:[NSString stringWithFormat:@"Get %d Symbols From Server", (int)(fillArray.count + iconArray.count)]];
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

- (void)addSymbols
{
    [self addToLog:[NSString stringWithFormat:@"======= addSymbols:\n%@%@", hostName, TY_API_UPLOAD_SYMBOLS]];
    [dataUploader uploadSymbolsWithFill:allFillSymbols Icons:allIconSymbols];
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

- (void)getSymbols
{
    [self addToLog:[NSString stringWithFormat:@"======= getSymbols:\n%@%@", hostName, TY_API_GET_TARGET_MAPINFO]];
    [dataDownloader getSymbols];
}


- (IBAction)uploadCurrentBuildingData:(id)sender {
    NSLog(@"uploadCurrentBuildingData");
    [self addCities];
    [self addBuildings];
    [self addMapInfos];
    [self addSymbols];
}

- (IBAction)getCurrentBuildingData:(id)sender {
    NSLog(@"getCurrentBuildingData");
    [self getCities];
    [self getBuildings];
    [self getMapInfos];
    [self getSymbols];
}
@end
