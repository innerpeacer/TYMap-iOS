//
//  TYMapDataManager.m
//  MapProject
//
//  Created by innerpeacer on 15/12/18.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYMapDataManager.h"
#import "IPSyncDataManager.h"
#import "TYMapEnviroment.h"

@interface TYMapDataManager() <IPSyncDataManagerDelegate>
{
    IPSyncDataManager *syncManager;
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
        syncManager = [[IPSyncDataManager alloc] initWithUser:mapCredential RootDirectory:[TYMapEnvironment getRootDirectoryForMapFiles]];
        syncManager.delegate = self;
    }
    return self;
}

- (void)fetchMapData
{
    [syncManager fetchData];
}

- (void)SyncDataManagerDidFailedSyncData:(IPSyncDataManager *)manager InStep:(int)step WithError:(NSError *)error
{
    [self notifyFailedFetchingData:error];
}

- (void)SyncDataManagerDidFinishDownloadingSyncData:(IPSyncDataManager *)manager
{
    
}

- (void)SyncDataManagerDidFinishSyncData:(IPSyncDataManager *)manager
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
