//
//  TYSyncDataManager.h
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"
#import <TYMapData/TYMapData.h>

@class IPSyncDataManager;

@protocol IPSyncDataManagerDelegate <NSObject>

- (void)SyncDataManagerDidFinishSyncData:(IPSyncDataManager *)manager;
- (void)SyncDataManagerDidFinishDownloadingSyncData:(IPSyncDataManager *)manager;
- (void)SyncDataManagerDidFailedSyncData:(IPSyncDataManager *)manager InStep:(int)step WithError:(NSError *)error;

@end

@interface IPSyncDataManager : NSObject

@property (nonatomic, weak) id<IPSyncDataManagerDelegate> delegate;

- (id)initWithUser:(TYMapCredential *)user RootDirectory:(NSString *)root;
- (void)fetchData;

//- (void)checkDir;
//+ (TYSyncDataManager *)managerWithRootDirectory:(NSString *)rootDir;

//- (void)checkDir;

//- (void)checkRootDir;
//- (void)checkCityDir:(NSString *)cityID;
//- (void)checkBuildingDir:(NSString *)buildingID;

@end

