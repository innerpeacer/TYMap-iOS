//
//  TYCityManager.m
//  MapProject
//
//  Created by innerpeacer on 15/9/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYCityManager.h"
#import "IPMapFileManager.h"
#import "IPMapDBAdapter.h"



@implementation TYCityManager

+ (NSArray *)parseAllCities
{
    NSString *dbPath = [IPMapFileManager getMapDBPath];
    IPMapDBAdapter *db = [[IPMapDBAdapter alloc] initWithPath:dbPath];
    [db open];
    NSArray *resultArray = [db getAllCities];
    [db close];
    return resultArray;
}

+ (TYCity *)parseCity:(NSString *)cityID
{
    NSString *dbPath = [IPMapFileManager getMapDBPath];
    IPMapDBAdapter *db = [[IPMapDBAdapter alloc] initWithPath:dbPath];
    [db open];
    TYCity *resultCity = [db getCity:cityID];
    [db close];
    return resultCity;
}




@end
