//
//  UploadCityBuildingVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "UploadCityBuildingVC.h"
#import "TYCityManager.h"
#import "TYBuildingManager.h"
#import "TYMapInfo.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "TYUserManager.h"
#import "IPSyncMapDBAdapter.h"
#import "IPCBMUploader.h"
#import "IPCBMDownloader.h"

@interface UploadAllCityBuildingVC() <IPCBMUploaderDelegate, IPCBMDownloaderDelegate>
{
    NSArray *allCities;
    NSArray *allBuildings;
    NSArray *allMapInfos;
    
    NSString *hostName;
    
    IPCBMUploader *webUploader;
    IPCBMDownloader *webDownloader;
}

- (IBAction)uploadCitiesAndBuildings:(id)sender;
- (IBAction)getCitiesAndBuildings:(id)sender;
@end

@implementation UploadAllCityBuildingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hostName = HOST_NAME;
    
    
    webUploader = [[IPCBMUploader alloc] initWithUser:[TYUserManager createSuperUser:@"00000000"]];
    //    webUploader = [[TYCBMUploader alloc] initWithUser:[TYUserManager createTrialUser:@"00000000"]];
    webUploader.delegate = self;
    webDownloader = [[IPCBMDownloader alloc] initWithUser:[TYUserManager createSuperUser:@"00000000"]];
    webDownloader.delegate = self;
    
    allCities = [TYCityManager parseAllCities];
    NSMutableArray *buildingArray = [NSMutableArray array];
    NSMutableArray *mapInfoArray = [NSMutableArray array];
    for (TYCity *city in allCities) {
        NSArray *buildings = [TYBuildingManager parseAllBuildings:city];
        [buildingArray addObjectsFromArray:buildings];
        
        for (TYBuilding *building in buildings) {
            NSArray *mapInfos = [TYMapInfo parseAllMapInfo:building];
            [mapInfoArray addObjectsFromArray:mapInfos];
        }
    }
    allBuildings = buildingArray;
    allMapInfos = mapInfoArray;
}

- (void)CBMUploader:(IPCBMUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataUploaderDidFailedUploading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)CBMUploader:(IPCBMUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)responseString
{
    [self addToLog:responseString];
}

- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    if ([api isEqualToString:TY_API_GET_ALL_CITIES]) {
        [self addToLog:[NSString stringWithFormat:@"Records: %d", records]];
        [self addToLog:[NSString stringWithFormat:@"Get %d Cities From Server", (int)resultArray.count]];
        NSMutableString *cityString = [NSMutableString string];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TYCity *c = obj;
            [cityString appendFormat:@"[%@] ", c.name];
        }];
//        [self addToLog:cityString];
    }
    
    if ([api isEqualToString:TY_API_GET_ALL_BUILDINGS]) {
        [self addToLog:[NSString stringWithFormat:@"Records: %d", records]];
        [self addToLog:[NSString stringWithFormat:@"Get %d Buildings From Server", (int)resultArray.count]];
        NSMutableString *buildingString = [NSMutableString string];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TYBuilding *b = obj;
            [buildingString appendFormat:@"[%@] ", b.name];
        }];
//        [self addToLog:buildingString];
    }
    
    if ([api isEqualToString:TY_API_GET_ALL_MAPINFOS]) {
        [self addToLog:[NSString stringWithFormat:@"Records: %d", records]];
        [self addToLog:[NSString stringWithFormat:@"Get %d MapInfos From Server", (int)resultArray.count]];
        NSMutableString *mapInfoString = [NSMutableString string];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TYMapInfo *m = obj;
            [mapInfoString appendFormat:@"[%@] ", m.mapID];
        }];
//        [self addToLog:mapInfoString];
    }
    
}

- (void)CBMDownlaoder:(IPCBMDownloader *)downloader DidFinishDownloadingCityBuildingsWithApi:(NSString *)api WithCities:(NSArray *)cityArray Buildings:(NSArray *)buildingArray
{
    [self addToLog:[NSString stringWithFormat:@"Records: %d", (int)(cityArray.count + buildingArray.count)]];
    [self addToLog:[NSString stringWithFormat:@"Get %d Cities, %d Buildings From Server", (int)cityArray.count, (int)buildingArray.count]];
}

- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataDownloaderDidFailedDownloading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)uploadAllCities
{
    [self addToLog:[NSString stringWithFormat:@"======= uploadAllCities:\n%@%@", hostName, TY_API_UPLOAD_ALL_CITIES]];
    [webUploader uploadCities:allCities];
}


- (void)uploadAllBuildings
{
    [self addToLog:[NSString stringWithFormat:@"======= uploadAllBuildings:\n%@%@", hostName, TY_API_UPLOAD_ALL_BUILDINGS]];
    [webUploader uploadBuildings:allBuildings];
}

- (void)uploadAllMapInfos
{
    [self addToLog:[NSString stringWithFormat:@"======= uploadAllMapInfos:\n%@%@", hostName, TY_API_UPLOAD_ALL_MAPINFOS]];
    [webUploader uploadMapInfos:allMapInfos];
}

- (void)getAllCities
{
    [self addToLog:[NSString stringWithFormat:@"======= getAllCities:\n%@%@", hostName, TY_API_GET_ALL_CITIES]];
    [webDownloader getAllCities];
}

- (void)getAllBuildings
{
    [self addToLog:[NSString stringWithFormat:@"======= getAllBuildings:\n%@%@", hostName, TY_API_GET_ALL_BUILDINGS]];
    [webDownloader getAllBuildings];
}

- (void)getAllMapInfos
{
    [self addToLog:[NSString stringWithFormat:@"======= getAllMapInfos:\n%@%@", hostName, TY_API_GET_ALL_MAPINFOS]];
    [webDownloader getAllMapInfos];
}

- (void)getAllCityBuildings
{
    [self addToLog:[NSString stringWithFormat:@"======= getAllCityBuildings:\n%@%@", hostName, TY_API_GET_ALL_CITY_BUILDINGS]];
    [webDownloader getAllCityBuildings];
}

- (IBAction)uploadCitiesAndBuildings:(id)sender {
    NSLog(@"uploadCitiesAndBuildings");
    [self uploadAllCities];
    [self uploadAllBuildings];
    [self uploadAllMapInfos];
}

- (IBAction)getCitiesAndBuildings:(id)sender {
    NSLog(@"getCitiesAndBuildings");
    [self getAllCities];
    [self getAllBuildings];
    [self getAllMapInfos];
    [self getAllCityBuildings];
}


@end