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
#import "TYWebObjectConverter.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "TYUserManager.h"
#import "TYMapFileManager.h"

#import "TYSyncMapDataDBAdapter.h"
#import "TYSyncMapRouteDBAdapter.h"
#import "TYSyncMapSymbolDBAdapter.h"

#import "TYSyncUploadingTask.h"
#import "TYSyncDownloadingTask.h"

@interface UploadCompleteDataVC() <TYSyncUploadingTaskDelegate, TySyncDownloadingTaskDelegate>
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
    
    TYSyncUploadingTask *uploadingTask;
    TYSyncDownloadingTask *downloadingTask;
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

    uploadingTask = [[TYSyncUploadingTask alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID]];
    uploadingTask.delegate = self;
    
    downloadingTask = [[TYSyncDownloadingTask alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    downloadingTask.delegate = self;
    
    NSLog(@"%@", currentCity);
    NSLog(@"%@", currentBuilding);
    NSLog(@"%@", allMapInfos);
}

- (void)TYUploadingTaskDidFailedUploading:(TYSyncUploadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    
}

- (void)TYUploadingTaskDidFinished:(TYSyncUploadingTask *)task
{
    [self addToLog:@"Finish Uploading"];
}

- (void)TYUploadingTaskDidUpdateUploadingProcess:(TYSyncUploadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    [self addToLog:[NSString stringWithFormat:@"Step %d:", step]];
    [self addToLog:description];
}

- (void)TYDownloadingTaskDidFailedDownloading:(TYSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    
}

- (void)TYDownloadingTaskDidFinished:(TYSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray
{
    [self addToLog:@"Finish Downloading"];
}

- (void)TYDownloadingTaskDidUpdateDownloadingProcess:(TYSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    [self addToLog:[NSString stringWithFormat:@"Step %d:", step]];
    [self addToLog:description];
}

- (void)prepareData
{
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];
    
    TYSyncMapDataDBAdapter *dataDB = [[TYSyncMapDataDBAdapter alloc] initWithPath:[TYMapFileManager getMapDataDBPath:currentBuilding]];
    [dataDB open];
    allMapDataRecords = [dataDB getAllRecords];
    [dataDB close];
    
    
    TYSyncMapRouteDBAdapter *routeDB = [[TYSyncMapRouteDBAdapter alloc] initWithPath:[TYMapFileManager getMapDataDBPath:currentBuilding]];
    [routeDB open];
    allRouteLinkRecords = [routeDB getAllRouteLinkRecords];
    allRouteNodeRecords = [routeDB getAllRouteNodeRecords];
    [routeDB close];

    TYSyncMapSymbolDBAdapter *symbolDB = [[TYSyncMapSymbolDBAdapter alloc] initWithPath:[TYMapFileManager getSymbolDBPath:currentBuilding]];
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
