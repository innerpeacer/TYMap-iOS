//
//  TYSyncDataManager.h
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYSyncDataManager : NSObject

+ (TYSyncDataManager *)managerWithRootDirectory:(NSString *)rootDir;

- (void)checkRootDir;
- (void)checkCityDir:(NSString *)cityID;
- (void)checkBuildingDir:(NSString *)buildingID;

@end
