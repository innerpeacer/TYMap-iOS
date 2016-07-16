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
#import "IPMapWebObjectConverter.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "TYUserManager.h"
#import "IPMapFileManager.h"

#import "IPSyncMapDataDBAdapter.h"
#import "IPSyncMapRouteDBAdapter.h"
#import "IPSyncMapSymbolDBAdapter.h"

#import "IPSyncUploadingTask.h"
#import "IPMapSyncDownloadingTask.h"

@interface UploadCompleteDataVC() <IPSyncUploadingTaskDelegate, IPMapSyncDownloadingTaskDelegate>
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
    IPMapSyncDownloadingTask *downloadingTask;
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
    
    downloadingTask = [[IPMapSyncDownloadingTask alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    downloadingTask.delegate = self;
    
    NSLog(@"%@", currentCity);
    NSLog(@"%@", currentBuilding);
    NSLog(@"%@", allMapInfos);
}

- (void)requestGenerateMapDataZip
{
    [self addToLog:@"请求生成地图数据"];
    NSLog(@"requestGenerateMapDataZip");
    NSDictionary *params = @{@"buildingID": currentBuilding.buildingID};
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName];
    MKNetworkOperation *op = [engine operationWithPath:TY_API_MOBILE_GENERATE_MAP_ZIP params:params httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"completion");
        NSLog(@"%@", operation.responseString);
        [self addToLog:[NSString stringWithFormat:@"完成: %@", operation.responseString]];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"error");
        NSLog(@"%@", completedOperation.responseString);
        [self addToLog:[NSString stringWithFormat:@"错误: %@", completedOperation.responseString]];
    }];
    [engine enqueueOperation:op];
}

- (void)UploadingTaskDidFailedUploading:(IPSyncUploadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    
}

- (void)UploadingTaskDidFinished:(IPSyncUploadingTask *)task
{
    [self addToLog:@"Finish Uploading"];
    [self requestGenerateMapDataZip];
}

- (void)UploadingTaskDidUpdateUploadingProcess:(IPSyncUploadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    [self addToLog:[NSString stringWithFormat:@"Step %d:", step]];
    [self addToLog:description];
}

- (void)DownloadingTaskDidFailedDownloading:(IPMapSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    
}

- (void)DownloadingTaskDidFinished:(IPMapSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray
{
    [self addToLog:@"Finish Downloading"];
}

- (void)DownloadingTaskDidUpdateDownloadingProcess:(IPMapSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description
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
