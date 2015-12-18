//
//  TYMapDataManager.m
//  MapProject
//
//  Created by innerpeacer on 15/12/18.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYMapDataManager.h"
#import "TYSyncDataManager.h"
#import "TYMapEnviroment.h"

@interface TYMapDataManager() <TYSyncDataManagerDelegate>
{
    TYSyncDataManager *syncManager;
    TYMapCredential *mapCredential;
    
    TYBuilding *currentBuilding;
}

@end

@implementation TYMapDataManager


- (id)initWithUserID:(NSString *)userID BuildingID:(NSString *)buildingID License:(NSString *)license
{
    self = [super init];
    if (self) {
        mapCredential = [TYMapCredential credentialWithUserID:userID BuildingID:buildingID License:license];
        syncManager = [[TYSyncDataManager alloc] initWithUser:mapCredential RootDirectory:[TYMapEnvironment getRootDirectoryForMapFiles]];
        syncManager.delegate = self;
    }
    return self;
}

- (void)fetchMapData
{
    [syncManager fetchData];
}

- (void)TYSyncDataManagerDidFailedSyncData:(TYSyncDataManager *)manager InStep:(int)step WithError:(NSError *)error
{
    [self notifyFailedFetchingData:error];
}

- (void)TYSyncDataManagerDidFinishDownloadingSyncData:(TYSyncDataManager *)manager
{
    
}

- (void)TYSyncDataManagerDidFinishSyncData:(TYSyncDataManager *)manager
{
    [self notifyFinishFetchingData];
}


- (void)notifyFinishFetchingData
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYMapDataManagerDidFinishFetchingData:)]) {
        [self.delegate TYMapDataManagerDidFinishFetchingData:self];
    }
}

- (void)notifyFailedFetchingData:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYMapDataManagerDidFailedFetchingData:WithError:)]) {
        [self.delegate TYMapDataManagerDidFailedFetchingData:self WithError:error];
    }
}

@end
