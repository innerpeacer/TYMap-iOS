//
//  LicenseManager.m
//  MapProject
//
//  Created by innerpeacer on 15/9/22.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "LicenseManager.h"

#define KEY_USER_ID @"UserID"
#define KEY_BUILDING_ID @"BuildingID"
#define KEY_LICENSE @"License"
#define KEY_EXPIRATION_DATE @"Expiration Date"

@implementation LicenseManager

static NSDictionary *allLicenseDictionary;

+ (NSDictionary *)getLicenseForBuilding:(NSString *)building
{
    if (allLicenseDictionary == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Licenses" ofType:@"json"];
        allLicenseDictionary = [LicenseManager parseAllLicenses:path];
    }
    
    return [allLicenseDictionary objectForKey:building];
}

+ (NSDictionary *)parseAllLicenses:(NSString *)path
{
    NSMutableDictionary *allLicenseDict = [NSMutableDictionary dictionary];

    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        
        for (NSDictionary *dict in array) {
            NSString *userID = [dict objectForKey:KEY_USER_ID];
            NSString *buildingID = [dict objectForKey:KEY_BUILDING_ID];
            NSString *license = [dict objectForKey:KEY_LICENSE];
            NSString *expiredDate = [dict objectForKey:KEY_EXPIRATION_DATE];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:userID forKeyedSubscript:@"UserID"];
            [dict setObject:buildingID forKeyedSubscript:@"BuildingID"];
            [dict setObject:license forKey:@"License"];
            [dict setObject:expiredDate forKeyedSubscript:@"Expiration Date"];
            
            [allLicenseDict setObject:dict forKey:buildingID];
        }
    }
    return allLicenseDict;
}

@end

