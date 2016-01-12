//
//  TYUserManager.h
//  MapProject
//
//  Created by innerpeacer on 15/11/25.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>
#import "TYMapCredential.h"

@interface TYUserManager : NSObject

+ (NSString *)getTrialUserID;
+ (NSString *)getTrialUserLicense:(TYBuilding *)building;
+ (NSString *)getSuperUserID;
+ (NSString *)getSuperUserLicense:(TYBuilding *)building;
+ (NSDictionary *)getTrialUserDictionay:(TYBuilding *)building;
+ (NSDictionary *)getSuperUserDictionay:(TYBuilding *)building;

+ (TYMapCredential *)createSuperUser:(NSString *)buildingID;
+ (TYMapCredential *)createTrialUser:(NSString *)buildingID;
+ (TYMapCredential *)createWrongUser:(NSString *)buildingID;

@end