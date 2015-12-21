//
//  UploadCompleteDataVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "UploadCompleteDataVC.h"
#import <TYMapData/TYMapData.h>
#import "TYCityManager.h"
#import "TYBuildingManager.h"
#import "TYUserDefaults.h"
#import "TYMapInfo.h"
#import "IPWebObjectConverter.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "TYUserManager.h"
#import "IPMapFileManager.h"

#import "IPSyncMapDataDBAdapter.h"
#import "IPSyncMapRouteDBAdapter.h"
#import "IPSyncMapSymbolDBAdapter.h"

#import "IPSyncUploadingTask.h"
#import "IPSyncDownloadingTask.h"

@interface UploadCompleteDataVC() <IPSyncUploadingTaskDelegate, IPSyncDownloadingTaskDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSArray *allMapInfos;
    
    NSArray *allMapDataRecords;
    NSArray *allRouteLinkRecords;
    NSArray *allRouteNodeRecords;
    
    NSArray *allFillSymbols;
    NSArray *allIconSymbols;
    
    NSString *hostName;
    
    IPSyncUploadingTask *uploadingTask;
    IPSyncDownloadingTask *downloadingTask;
}

- (IBAction)uploadCompleteData:(id)sender;
- (IBAction)getCompleteData:(id)sender;

@end

@implementation UploadCompleteDataVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    hostName = HOST_NAME;
    
    [self prepareData];

    uploadingTask = [[IPSyncUploadingTask alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID]];
    uploadingTask.delegate = self;
    
    downloadingTask = [[IPSyncDownloadingTask alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    downloadingTask.delegate = self;
    
    NSLog(@"%@", currentCity);
    NSLog(@"%@", currentBuilding);
    NSLog(@"%@", allMapInfos);
}

- (void)TYUploadingTaskDidFailedUploading:(IPSyncUploadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    
}

- (void)TYUploadingTaskDidFinished:(IPSyncUploadingTask *)task
{
    [self addToLog:@"Finish Uploading"];
}

- (void)TYUploadingTaskDidUpdateUploadingProcess:(IPSyncUploadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    [self addToLog:[NSString stringWithFormat:@"Step %d:", step]];
    [self addToLog:description];
}

- (void)TYDownloadingTaskDidFailedDownloading:(IPSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    
}

- (void)TYDownloadingTaskDidFinished:(IPSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray
{
    [self addToLog:@"Finish Downloading"];
}

- (void)TYDownloadingTaskDidUpdateDownloadingProcess:(IPSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    [self addToLog:[NSString stringWithFormat:@"Step %d:", step]];
    [self addToLog:description];
}

- (void)prepareData
{
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];
    
    IPSyncMapDataDBAdapter *dataDB = [[IPSyncMapDataDBAdapter alloc] initWithPath:[IPMapFileManager getMapDataDBPath:currentBuilding]];
    [dataDB open];
    allMapDataRecords = [dataDB getAllRecords];
    [dataDB close];
    
    
    IPSyncMapRouteDBAdapter *routeDB = [[IPSyncMapRouteDBAdapter alloc] initWithPath:[IPMapFileManager getMapDataDBPath:currentBuilding]];
    [routeDB open];
    allRouteLinkRecords = [routeDB getAllRouteLinkRecords];
    allRouteNodeRecords = [routeDB getAllRouteNodeRecords];
    [routeDB close];

    IPSyncMapSymbolDBAdapter *symbolDB = [[IPSyncMapSymbolDBAdapter alloc] initWithPath:[IPMapFileManager getSymbolDBPath:currentBuilding]];
    [symbolDB open];
    allFillSymbols = [symbolDB getAllFillSymbols];
    allIconSymbols = [symbolDB getAllIconSymbols];
    [symbolDB close];
}

- (IBAction)uploadCompleteData:(id)sender
{
    NSLog(@"uploadCompleteData");
    [uploadingTask uploadCity:currentCity Building:currentBuilding MapInfos:allMapInfos FillSymbols:allFillSymbols IconSymbols:allIconSymbols MapData:allMapDataRecords RouteLinkData:allRouteLinkRecords RouteNodeData:allRouteNodeRecords];
}

- (IBAction)getCompleteData:(id)sender
{
    NSLog(@"getCompleteData");
    [downloadingTask featchData];
}

@end
