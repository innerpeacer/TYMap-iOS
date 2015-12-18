//
//  TYSyncDataManager.m
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYSyncDataManager.h"
#import <TYMapData/TYMapData.h>
#import "TYSyncDownloadingTask.h"

#import "TYSyncMapDataDBAdapter.h"
#import "TYSyncMapSymbolDBAdapter.h"
#import "TYSyncMapDBAdapter.h"
#import "TYSyncMapRouteDBAdapter.h"

@interface TYSyncDataManager() <TySyncDownloadingTaskDelegate>
{
    NSString *rootDir;
    TYMapCredential *mapUser;
    
    TYSyncDownloadingTask *downloadingTask;
}

@end

@implementation TYSyncDataManager

- (id)initWithUser:(TYMapCredential *)user RootDirectory:(NSString *)root;
{
    self = [super init];
    if (self) {
        mapUser = user;
        rootDir = root;
        
        downloadingTask = [[TYSyncDownloadingTask alloc] initWithUser:user];
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

- (void)TYDownloadingTaskDidFailedDownloading:(TYSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    [self notifyFailedInStep:step WithError:error];
}

- (void)TYDownloadingTaskDidFinished:(TYSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)b MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray
{
    NSLog(@"Finish Downloading");
    
    [self notifyFinishDownloadingSyncData];
    
    [self checkDir:b];
    
    TYSyncMapDBAdapter *mapDB = [[TYSyncMapDBAdapter alloc] initWithPath:[self getMapDBPath]];
    [mapDB open];
    [mapDB deleteCity:city.cityID];
    [mapDB insertCity:city];
    [mapDB deleteBuilding:b.buildingID];
    [mapDB insertBuilding:b];
    [mapDB close];
    
    TYSyncMapDataDBAdapter *mapdataDB = [[TYSyncMapDataDBAdapter alloc] initWithPath:[self getMapDataDBPath:b]];
    [mapdataDB open];
    [mapdataDB eraseMapDataTable];
    [mapdataDB eraseMapInfoTable];
    [mapdataDB insertMapDataRecords:mapDataArray];
    [mapdataDB insertMapInfos:mapInfoArray];
    [mapdataDB close];
    
    TYSyncMapSymbolDBAdapter *symbolDB = [[TYSyncMapSymbolDBAdapter alloc] initWithPath:[self getMapDataDBPath:b]];
    [symbolDB open];
    [symbolDB eraseSymbolTable];
    [symbolDB insertFillSymbols:fillArray];
    [symbolDB insertIconSymbols:iconArray];
    [symbolDB close];
    
    TYSyncMapRouteDBAdapter *routeDB = [[TYSyncMapRouteDBAdapter alloc] initWithPath:[self getMapDataDBPath:b]];
    [routeDB open];
    [routeDB eraseRouteDataTable];
    [routeDB insertRouteLinkRecords:linkArray];
    [routeDB insertRouteNodeRecords:nodeArray];
    [routeDB close];
    
    [self notifyFinishSyncData];

}

- (void)TYDownloadingTaskDidUpdateDownloadingProcess:(TYSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    NSLog(@"Step %d: %@", step, description);
}

- (void)notifyFinishSyncData
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYSyncDataManagerDidFinishSyncData:)]) {
        [self.delegate TYSyncDataManagerDidFinishSyncData:self];
    }
}

- (void)notifyFinishDownloadingSyncData
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYSyncDataManagerDidFinishDownloadingSyncData:)]) {
        [self.delegate TYSyncDataManagerDidFinishDownloadingSyncData:self];
    }
}


- (void)notifyFailedInStep:(int)step WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYSyncDataManagerDidFailedSyncData:InStep:WithError:)]) {
        [self.delegate TYSyncDataManagerDidFailedSyncData:self InStep:step WithError:error];
    }
}

@end
