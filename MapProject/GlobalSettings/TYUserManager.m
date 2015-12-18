//
//  TYUserManager.m
//  MapProject
//
//  Created by innerpeacer on 15/11/25.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYUserManager.h"
#import "MapLicenseGenerator.h"
@implementation TYUserManager

+ (NSString *)getTrialUserID
{
    return TRIAL_USER_ID;
}

+ (NSString *)getTrialUserLicense:(TYBuilding *)building
{
    return [MapLicenseGenerator generateLicenseForUserID:TRIAL_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
}

+ (NSString *)getSuperUserID
{
    return SUPER_USER_ID;
}

+ (NSString *)getSuperUserLicense:(TYBuilding *)building
{
    return [MapLicenseGenerator generateLicenseForUserID:SUPER_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
}

+ (NSDictionary *)getTrialUserDictionay:(TYBuilding *)building
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"userID"] = TRIAL_USER_ID;
    dict[@"buildingID"] = building.buildingID;
    dict[@"license"] = [MapLicenseGenerator generateLicenseForUserID:TRIAL_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    return dict;
}

+ (NSDictionary *)getSuperUserDictionay:(TYBuilding *)building
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"userID"] = SUPER_USER_ID;
    dict[@"buildingID"] = building.buildingID;
    dict[@"license"] = [MapLicenseGenerator generateLicenseForUserID:SUPER_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    return dict;
}

+ (TYMapCredential *)createSuperUser:(NSString *)buildingID
{
    return [TYMapCredential userWithID:SUPER_USER_ID BuildingID:buildingID License:[MapLicenseGenerator generateLicenseForUserID:SUPER_USER_ID Building:buildingID ExpiredDate:TRIAL_EXPRIED_DATE]];
}

+ (TYMapCredential *)createTrialUser:(NSString *)buildingID
{
    return [TYMapCredential userWithID:TRIAL_USER_ID BuildingID:buildingID License:[MapLicenseGenerator generateLicenseForUserID:TRIAL_USER_ID Building:buildingID ExpiredDate:TRIAL_EXPRIED_DATE]];
}

+ (TYMapCredential *)createWrongUser:(NSString *)buildingID
{
    return [TYMapCredential userWithID:TRIAL_USER_ID BuildingID:@"00000000" License:@"088f90995f3dan0a25ga21207238faec"];
}

@end
