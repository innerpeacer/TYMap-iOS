//
//  NPUserDefaults.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPUserDefaults.h"

#define KEY_BUILDING_ID @"buildingID"
#define KEY_CITY_ID @"cityID"

@implementation NPUserDefaults

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

+ (NSString *)getDefaultBuilding
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *buildingID = [defaults objectForKey:KEY_BUILDING_ID];
    return buildingID;
}

+ (NSString *)getDefaultCity
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cityID = [defaults objectForKey:KEY_CITY_ID];
    return cityID;
}

@end
