//
//  TYCityManager.m
//  MapProject
//
//  Created by innerpeacer on 15/9/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYCityManager.h"
#import "TYMapFileManager.h"
#import "TYMapDBAdapter.h"



@implementation TYCityManager

+ (NSArray *)parseAllCities
{
    NSString *dbPath = [TYMapFileManager getMapDBPath];
    TYMapDBAdapter *db = [[TYMapDBAdapter alloc] initWithPath:dbPath];
    [db open];
    NSArray *resultArray = [db getAllCities];
    [db close];
    return resultArray;
}

+ (TYCity *)parseCity:(NSString *)cityID
{
    NSString *dbPath = [TYMapFileManager getMapDBPath];
    TYMapDBAdapter *db = [[TYMapDBAdapter alloc] initWithPath:dbPath];
    [db open];
    TYCity *resultCity = [db getCity:cityID];
    [db close];
    return resultCity;
}




@end
