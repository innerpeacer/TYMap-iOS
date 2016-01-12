//
//  TYSyncDownloadingTask.m
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPMapSyncDownloadingTask.h"


#define TY_SYNC_DOWNLOADING_STEP_UNKNOWN 0
#define TY_SYNC_DOWNLOADING_STEP_CBM 1
#define TY_SYNC_DOWNLOADING_STEP_SYMBOLS 2
#define TY_SYNC_DOWNLOADING_STEP_MAP_DATA 3
#define TY_SYNC_DOWNLOADING_STEP_ROUTE 4
#define TY_SYNC_DOWNLOADING_STEP_FINISH 100

#import "IPCBMDownloader.h"
#import "IPMapDataDownloader.h"
#import "IPRouteDataDownloader.h"

@interface IPMapSyncDownloadingTask() <IPCBMDownloaderDelegate, IPMapDataDownloaderDelegate, IPRouteDataDownloaderDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSArray *allMapInfos;
    
    NSArray *allMapDataRecords;
    NSArray *allRouteLinkRecords;
    NSArray *allRouteNodeRecords;
    
    NSArray *allFillSymbols;
    NSArray *allIconSymbols;

    int downloadingStep;
    IPCBMDownloader *cbmDownloader;
    IPMapDataDownloader *mapDownloader;
    IPRouteDataDownloader *routeDownloader;
}

@end

@implementation IPMapSyncDownloadingTask

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        downloadingStep = TY_SYNC_DOWNLOADING_STEP_UNKNOWN;
        cbmDownloader = [[IPCBMDownloader alloc] initWithUser:u];
        cbmDownloader.delegate = self;
        mapDownloader = [[IPMapDataDownloader alloc] initWithUser:u];
        mapDownloader.delegate = self;
        routeDownloader = [[IPRouteDataDownloader alloc] initWithUser:u];
        routeDownloader.delegate = self;
    }
    return self;
}

- (void)featchData
{
    downloadingStep = TY_SYNC_DOWNLOADING_STEP_CBM;
    [self performDownloadingStep];
}

- (void)finishDownloaingStep
{
    switch (downloadingStep) {
        case TY_SYNC_DOWNLOADING_STEP_CBM:
            downloadingStep = TY_SYNC_DOWNLOADING_STEP_SYMBOLS;
            [self performDownloadingStep];
            break;
            
        case TY_SYNC_DOWNLOADING_STEP_SYMBOLS:
            downloadingStep = TY_SYNC_DOWNLOADING_STEP_MAP_DATA;
            [self performDownloadingStep];
            break;
            
        case TY_SYNC_DOWNLOADING_STEP_MAP_DATA:
            downloadingStep = TY_SYNC_DOWNLOADING_STEP_ROUTE;
            [self performDownloadingStep];
            break;
            
        case TY_SYNC_DOWNLOADING_STEP_ROUTE:
            downloadingStep = TY_SYNC_DOWNLOADING_STEP_FINISH;
            [self notifyFinished:self WithCity:currentCity Building:currentBuilding MapInfos:allMapInfos FillSymbols:allFillSymbols IconSymbols:allIconSymbols MapData:allMapDataRecords RouteLinkData:allRouteLinkRecords RouteNodeData:allRouteNodeRecords];
            break;
            
        default:
            break;
    }
}

- (void)performDownloadingStep
{
    switch (downloadingStep) {
        case TY_SYNC_DOWNLOADING_STEP_CBM:
            [cbmDownloader getCBM];
            break;
            
        case TY_SYNC_DOWNLOADING_STEP_SYMBOLS:
            [cbmDownloader getSymbols];
            break;
            
        case TY_SYNC_DOWNLOADING_STEP_MAP_DATA:
            [mapDownloader getAllMapDataRecords];
            break;
            
        case TY_SYNC_DOWNLOADING_STEP_ROUTE:
            [routeDownloader getAllRouteDataRecords];
            break;
            
        default:
            break;
    }
}

- (void)notifyFinished:(IPMapSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DownloadingTaskDidFinished:WithCity:Building:MapInfos:FillSymbols:IconSymbols:MapData:RouteLinkData:RouteNodeData:)]) {
        [self.delegate DownloadingTaskDidFinished:self WithCity:city Building:building MapInfos:mapInfoArray FillSymbols:fillArray IconSymbols:iconArray MapData:mapDataArray RouteLinkData:linkArray RouteNodeData:nodeArray];
    }
}

- (void)notifyFailedDownloading:(IPMapSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DownloadingTaskDidFailedDownloading:InStep:WithError:)]) {
        [self.delegate DownloadingTaskDidFailedDownloading:self InStep:step WithError:error];
    }
}

- (void)notifyDownloadingProcess:(IPMapSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DownloadingTaskDidUpdateDownloadingProcess:InStep:WithDescription:)]) {
        [self.delegate DownloadingTaskDidUpdateDownloadingProcess:self InStep:step WithDescription:description];
    }
}


#pragma mark -
#pragma mark Downloader Delegate
- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedDownloading:self InStep:downloadingStep WithError:error];
}

- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingSymbolsWithApi:(NSString *)api WithFillSymbols:(NSArray *)fillArray WithIconSymbols:(NSArray *)iconArray
{
    allFillSymbols = fillArray;
    allIconSymbols = iconArray;
    NSString *description = [NSString stringWithFormat:@"Get %d Symbols From Server", (int)(fillArray.count + iconArray.count)];
    [self notifyDownloadingProcess:self InStep:downloadingStep WithDescription:description];
    [self finishDownloaingStep];
}

- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingCBMWithApi:(NSString *)api WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    currentCity = city;
    currentBuilding = building;
    allMapInfos = mapInfoArray;
    NSString *description = [NSString stringWithFormat:@"Get City-Building-Mapinfos: %@-%@-%d", city.name, building.name, (int)mapInfoArray.count];
    [self notifyDownloadingProcess:self InStep:downloadingStep WithDescription:description];
    [self finishDownloaingStep];
}

- (void)MapDataDownloader:(IPMapDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedDownloading:self InStep:downloadingStep WithError:error];
}

- (void)MapDataDownloader:(IPMapDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    allMapDataRecords = resultArray;
    NSString *description = [NSString stringWithFormat:@"Get %d MapDataRecords From Server", (int)resultArray.count];
    [self notifyDownloadingProcess:self InStep:downloadingStep WithDescription:description];
    [self finishDownloaingStep];
}


- (void)RouteDataDownloader:(IPRouteDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithLinkResults:(NSArray *)linkArray WithNodeResults:(NSArray *)nodeArray
{
    allRouteLinkRecords = linkArray;
    allRouteNodeRecords = nodeArray;
    NSString *description = [NSString stringWithFormat:@"Get %d links and %d nodes From Server", (int)linkArray.count, (int)nodeArray.count];
    [self notifyDownloadingProcess:self InStep:downloadingStep WithDescription:description];
    [self finishDownloaingStep];
}

- (void)RouteDataDownloader:(IPRouteDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedDownloading:self InStep:downloadingStep WithError:error];
}

@end
