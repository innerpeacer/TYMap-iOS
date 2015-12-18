//
//  TYSyncDataManager.h
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapUser.h"
#import <TYMapData/TYMapData.h>

@class TYSyncDataManager;

@protocol TYSyncDataManagerDelegate <NSObject>

- (void)TYSyncDataManagerDidFinishSyncData:(TYSyncDataManager *)manager;
- (void)TYSyncDataManagerDidFailedSyncData:(TYSyncDataManager *)manager InStep:(int)step WithError:(NSError *)error;

@end

@interface TYSyncDataManager : NSObject

@property (nonatomic, weak) id<TYSyncDataManagerDelegate> delegate;

- (id)initWithUser:(TYMapUser *)user RootDirectory:(NSString *)root;
- (void)fetchData;

//- (void)checkDir;
//+ (TYSyncDataManager *)managerWithRootDirectory:(NSString *)rootDir;

//- (void)checkDir;

//- (void)checkRootDir;
//- (void)checkCityDir:(NSString *)cityID;
//- (void)checkBuildingDir:(NSString *)buildingID;

@end
