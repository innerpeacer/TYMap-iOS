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

@class IPMapSyncDataManager;

@protocol IPMapSyncDataManagerDelegate <NSObject>

- (void)SyncDataManagerDidFinishSyncData:(IPMapSyncDataManager *)manager;
- (void)SyncDataManagerDidFinishDownloadingSyncData:(IPMapSyncDataManager *)manager;
- (void)SyncDataManagerDidFailedSyncData:(IPMapSyncDataManager *)manager InStep:(int)step WithError:(NSError *)error;

@end

@interface IPMapSyncDataManager : NSObject

@property (nonatomic, weak) id<IPMapSyncDataManagerDelegate> delegate;

- (id)initWithUser:(TYMapCredential *)user RootDirectory:(NSString *)root;
- (void)fetchData;

//- (void)checkDir;
//+ (TYSyncDataManager *)managerWithRootDirectory:(NSString *)rootDir;

//- (void)checkDir;

//- (void)checkRootDir;
//- (void)checkCityDir:(NSString *)cityID;
//- (void)checkBuildingDir:(NSString *)buildingID;

@end

