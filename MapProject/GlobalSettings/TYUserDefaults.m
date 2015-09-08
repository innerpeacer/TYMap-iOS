//
//  TYUserDefaults.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//
 
#import "TYUserDefaults.h"
#import "TYCityManager.h"
#import "TYBuildingManager.h"

#define KEY_BUILDING_ID @"buildingID"
#define KEY_CITY_ID @"cityID"

@implementation TYUserDefaults

+ (void)setDefaultCity:(NSString *)cityID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:cityID forKey:KEY_CITY_ID];
}

+ (void)setDefaultBuilding:(NSString *)buildingID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:buildingID forKey:KEY_BUILDING_ID];
}

+ (TYBuilding *)getDefaultBuilding
{
    TYBuilding *building = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cityID = [defaults objectForKey:KEY_CITY_ID];
    NSString *buildingID = [defaults objectForKey:KEY_BUILDING_ID];
    
    if (cityID && buildingID) {
        TYCity *city = [TYCityManager parseCity:cityID];
        building = [TYBuildingManager parseBuilding:buildingID InCity:city];
    }
    return building;
}

+ (TYCity *)getDefaultCity
{
    TYCity *city = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cityID = [defaults objectForKey:KEY_CITY_ID];
    if (cityID) {
        city = [TYCityManager parseCity:cityID];
    }
    return city;
}


@end
