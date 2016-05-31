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

+ (BOOL)useBase64License
{
#if USE_BASE64_LICENSE
    return  YES;
#else
    return NO;
#endif
}

+ (NSString *)getTrialUserID
{
    return TRIAL_USER_ID;
}

+ (NSString *)getTrialUserLicense:(TYBuilding *)building
{
    if ([TYUserManager useBase64License]) {
        return [MapLicenseGenerator generateBase64License40ForUserID:TRIAL_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    } else {
        return [MapLicenseGenerator generateLicense32ForUserID:TRIAL_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    }
}

+ (NSString *)getSuperUserID
{
    return SUPER_USER_ID;
}

+ (NSString *)getSuperUserLicense:(TYBuilding *)building
{
    if ([TYUserManager useBase64License]) {
        return [MapLicenseGenerator generateBase64License40ForUserID:SUPER_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    } else {
        return [MapLicenseGenerator generateLicense32ForUserID:SUPER_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    }
}

+ (NSDictionary *)getTrialUserDictionay:(TYBuilding *)building
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"userID"] = TRIAL_USER_ID;
    dict[@"buildingID"] = building.buildingID;
    if ([TYUserManager useBase64License]) {
        dict[@"license"] = [MapLicenseGenerator generateBase64License40ForUserID:TRIAL_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    } else {
        dict[@"license"] = [MapLicenseGenerator generateLicense32ForUserID:TRIAL_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    }
    return dict;
}

+ (NSDictionary *)getSuperUserDictionay:(TYBuilding *)building
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"userID"] = SUPER_USER_ID;
    dict[@"buildingID"] = building.buildingID;
    if ([TYUserManager useBase64License]) {
        dict[@"license"] = [MapLicenseGenerator generateBase64License40ForUserID:SUPER_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    } else {
        dict[@"license"] = [MapLicenseGenerator generateLicense32ForUserID:SUPER_USER_ID Building:building.buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    }
    return dict;
}

+ (TYMapCredential *)createSuperUser:(NSString *)buildingID
{
    if ([TYUserManager useBase64License]) {
        return [TYMapCredential credentialWithUserID:SUPER_USER_ID BuildingID:buildingID License:[MapLicenseGenerator generateBase64License40ForUserID:SUPER_USER_ID Building:buildingID ExpiredDate:TRIAL_EXPRIED_DATE]];
    } else {
        return [TYMapCredential credentialWithUserID:SUPER_USER_ID BuildingID:buildingID License:[MapLicenseGenerator generateLicense32ForUserID:SUPER_USER_ID Building:buildingID ExpiredDate:TRIAL_EXPRIED_DATE]];
    }
}

+ (TYMapCredential *)createTrialUser:(NSString *)buildingID
{
    if ([TYUserManager useBase64License]) {
        return [TYMapCredential credentialWithUserID:TRIAL_USER_ID BuildingID:buildingID License:[MapLicenseGenerator generateBase64License40ForUserID:TRIAL_USER_ID Building:buildingID ExpiredDate:TRIAL_EXPRIED_DATE]];
    } else {
        return [TYMapCredential credentialWithUserID:TRIAL_USER_ID BuildingID:buildingID License:[MapLicenseGenerator generateLicense32ForUserID:TRIAL_USER_ID Building:buildingID ExpiredDate:TRIAL_EXPRIED_DATE]];
    }
}

+ (TYMapCredential *)createWrongUser:(NSString *)buildingID
{
    return [TYMapCredential credentialWithUserID:TRIAL_USER_ID BuildingID:@"00000000" License:@"088f90995f3dan0a25ga21207238faec"];
}

@end
