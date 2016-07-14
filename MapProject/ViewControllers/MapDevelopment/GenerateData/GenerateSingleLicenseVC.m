//
//  GenerateSingleLicenseVC.m
//  MapProject
//
//  Created by innerpeacer on 16/6/26.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "GenerateSingleLicenseVC.h"
#import "MapLicenseGenerator.h"
#import "TYCityManager.h"
#import "TYBuildingManager.h"
#import "TYUserManager.h"
#import "TYUserDefaults.h"

@interface GenerateSingleLicenseVC ()
{
    NSString *userID;
    NSString *expiredDate;
    NSString *currentBuldingID;
    
    TYCity *currentCity;
    TYBuilding *currentBuilding;
}
@end

@implementation GenerateSingleLicenseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userID = TRIAL_USER_ID;
    expiredDate = TRIAL_EXPRIED_DATE;
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    
    [self generateLicenseForCurrentBuilding];
}

- (void)generateLicenseForBuilding:(NSString *)buildingID
{
    NSString *license;
    if ([TYUserManager useBase64License]) {
        license = [MapLicenseGenerator generateBase64License40ForUserID:userID Building:buildingID ExpiredDate:expiredDate];
    } else {
        license = [MapLicenseGenerator generateLicense32ForUserID:userID Building:buildingID ExpiredDate:expiredDate];
    }
    NSLog(@"%@", license);
}

- (void)generateLicenseForCurrentBuilding
{
    NSMutableArray *allLicenseArray = [[NSMutableArray alloc] init];

    NSString *license;
    if ([TYUserManager useBase64License]) {
        license = [MapLicenseGenerator generateBase64License40ForUserID:userID Building:currentBuilding.buildingID ExpiredDate:expiredDate];
    } else {
        license = [MapLicenseGenerator generateLicense32ForUserID:userID Building:currentBuilding.buildingID ExpiredDate:expiredDate];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:userID forKeyedSubscript:@"UserID"];
    [dict setObject:currentBuilding.buildingID forKeyedSubscript:@"BuildingID"];
    [dict setObject:license forKey:@"License"];
    [dict setObject:expiredDate forKeyedSubscript:@"Expiration Date"];
    [allLicenseArray addObject:dict];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:allLicenseArray options:NSJSONWritingPrettyPrinted error:nil];
    
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"License-%@.json", currentBuilding.buildingID]];
    NSLog(@"%@", documentDirectory);
    [data writeToFile:path atomically:YES];
    
    [self addToLog:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}


- (void)generateAllLicenses
{
    NSMutableArray *allLicenseArray = [[NSMutableArray alloc] init];
    
    NSArray *allCities = [TYCityManager parseAllCities];
    for (TYCity *city in allCities) {
        NSArray *allBuildings = [TYBuildingManager parseAllBuildings:city];
        for (TYBuilding *building in allBuildings) {
            NSString *license;
            if ([TYUserManager useBase64License]) {
                license = [MapLicenseGenerator generateBase64License40ForUserID:userID Building:building.buildingID ExpiredDate:expiredDate];
            } else {
                license = [MapLicenseGenerator generateLicense32ForUserID:userID Building:building.buildingID ExpiredDate:expiredDate];
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:userID forKeyedSubscript:@"UserID"];
            [dict setObject:building.buildingID forKeyedSubscript:@"BuildingID"];
            [dict setObject:license forKey:@"License"];
            [dict setObject:expiredDate forKeyedSubscript:@"Expiration Date"];
            [allLicenseArray addObject:dict];
        }
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:allLicenseArray options:NSJSONWritingPrettyPrinted error:nil];
    
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"Licenses.json"];
    NSLog(@"%@", documentDirectory);
    [data writeToFile:path atomically:YES];
    
    [self addToLog:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

@end
