//
//  GenerateLicensesVC.m
//  MapProject
//
//  Created by innerpeacer on 15/9/22.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "GenerateLicensesVC.h"
#import "LicenseGenerator.h"
#import "TYCityManager.h"
#import "TYBuildingManager.h"

@interface GenerateLicensesVC()
{
    NSString *userID;
    NSString *expiredDate;
    NSString *currentBuldingID;
}

@end

@implementation GenerateLicensesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userID = TRIAL_USER_ID;
    expiredDate = TRIAL_EXPRIED_DATE;
    
    
//    [self generateLicenseForBuilding:@"00210000"];
    [self generateAllLicenses];
}

- (void)generateLicenseForBuilding:(NSString *)buildingID
{
    NSString *license = [LicenseGenerator generateLicenseForUserID:userID Building:buildingID ExpiredDate:expiredDate];
    NSLog(@"%@", license);
}


- (void)generateAllLicenses
{
    NSMutableArray *allLicenseArray = [[NSMutableArray alloc] init];
    
    NSArray *allCities = [TYCityManager parseAllCities];
    for (TYCity *city in allCities) {
        NSArray *allBuildings = [TYBuildingManager parseAllBuildings:city];
        for (TYBuilding *building in allBuildings) {
            NSString *license = [LicenseGenerator generateLicenseForUserID:userID Building:building.buildingID ExpiredDate:expiredDate];
            
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
