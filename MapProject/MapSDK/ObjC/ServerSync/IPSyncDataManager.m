//
//  TYSyncDataManager.m
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPSyncDataManager.h"
#import <TYMapData/TYMapData.h>
#import "IPSyncDownloadingTask.h"

#import "IPSyncMapDataDBAdapter.h"
#import "IPSyncMapSymbolDBAdapter.h"
#import "IPSyncMapDBAdapter.h"
#import "IPSyncMapRouteDBAdapter.h"

@interface IPSyncDataManager() <IPSyncDownloadingTaskDelegate>
{
    NSString *rootDir;
    TYMapCredential *mapUser;
    
    IPSyncDownloadingTask *downloadingTask;
}

@end

@implementation IPSyncDataManager

- (id)initWithUser:(TYMapCredential *)user RootDirectory:(NSString *)root;
{
    self = [super init];
    if (self) {
        mapUser = user;
        rootDir = root;
        
        downloadingTask = [[IPSyncDownloadingTask alloc] initWithUser:user];
        downloadingTask.delegate = self;
    }
    return self;
}



- (void)fetchData
{
    [downloadingTask featchData];
}

- (void)checkDir:(TYBuilding *)b
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cityDir = [rootDir stringByAppendingPathComponent:b.cityID];
    NSString *buildingDir = [cityDir stringByAppendingPathComponent:b.buildingID];
    if (![manager fileExistsAtPath:buildingDir]) {
        NSError *error = nil;
        [manager createDirectoryAtPath:buildingDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

- (NSString *)getMapDataDBPath:(TYBuilding *)b
{
    return [[[rootDir stringByAppendingPathComponent:b.cityID] stringByAppendingPathComponent:b.buildingID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tymap", b.buildingID]];
}

- (NSString *)getMapDBPath
{
    return [rootDir stringByAppendingPathComponent:@"TYMap.db"];
}

- (void)DownloadingTaskDidFailedDownloading:(IPSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    [self notifyFailedInStep:step WithError:error];
}

- (void)DownloadingTaskDidFinished:(IPSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)b MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray
{
    NSLog(@"Finish Downloading");
    
    [self notifyFinishDownloadingSyncData];
    
    [self checkDir:b];
    
    IPSyncMapDBAdapter *mapDB = [[IPSyncMapDBAdapter alloc] initWithPath:[self getMapDBPath]];
    [mapDB open];
    [mapDB deleteCity:city.cityID];
    [mapDB insertCity:city];
    [mapDB deleteBuilding:b.buildingID];
    [mapDB insertBuilding:b];
    [mapDB close];
    
    IPSyncMapDataDBAdapter *mapdataDB = [[IPSyncMapDataDBAdapter alloc] initWithPath:[self getMapDataDBPath:b]];
    [mapdataDB open];
    [mapdataDB eraseMapDataTable];
    [mapdataDB eraseMapInfoTable];
    [mapdataDB insertMapDataRecords:mapDataArray];
    [mapdataDB insertMapInfos:mapInfoArray];
    [mapdataDB close];
    
    IPSyncMapSymbolDBAdapter *symbolDB = [[IPSyncMapSymbolDBAdapter alloc] initWithPath:[self getMapDataDBPath:b]];
    [symbolDB open];
    [symbolDB eraseSymbolTable];
    [symbolDB insertFillSymbols:fillArray];
    [symbolDB insertIconSymbols:iconArray];
    [symbolDB close];
    
    IPSyncMapRouteDBAdapter *routeDB = [[IPSyncMapRouteDBAdapter alloc] initWithPath:[self getMapDataDBPath:b]];
    [routeDB open];
    [routeDB eraseRouteDataTable];
    [routeDB insertRouteLinkRecords:linkArray];
    [routeDB insertRouteNodeRecords:nodeArray];
    [routeDB close];
    
    [self notifyFinishSyncData];

}

- (void)DownloadingTaskDidUpdateDownloadingProcess:(IPSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    NSLog(@"Step %d: %@", step, description);
}

- (void)notifyFinishSyncData
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SyncDataManagerDidFinishSyncData:)]) {
        [self.delegate SyncDataManagerDidFinishSyncData:self];
    }
}

- (void)notifyFinishDownloadingSyncData
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SyncDataManagerDidFinishDownloadingSyncData:)]) {
        [self.delegate SyncDataManagerDidFinishDownloadingSyncData:self];
    }
}


- (void)notifyFailedInStep:(int)step WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SyncDataManagerDidFailedSyncData:InStep:WithError:)]) {
        [self.delegate SyncDataManagerDidFailedSyncData:self InStep:step WithError:error];
    }
}

@end
