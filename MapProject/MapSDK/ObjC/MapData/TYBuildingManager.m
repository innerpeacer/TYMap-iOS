//
//  TYBuildingManager.m
//  MapProject
//
//  Created by innerpeacer on 15/9/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYBuildingManager.h"
#import "TYMapFileManager.h"
#import "TYMapDBAdapter.h"

@implementation TYBuildingManager

+ (NSArray *)parseAllBuildings:(TYCity *)city
{
    NSString *dbPath = [TYMapFileManager getMapDBPath];
    TYMapDBAdapter *db = [[TYMapDBAdapter alloc] initWithPath:dbPath];
    [db open];
    NSArray *resultArray = [db getAllBuildings:city];
    [db close];
    return resultArray;
}

+ (TYBuilding *)parseBuilding:(NSString *)buildingID InCity:(TYCity *)city
{
    NSString *dbPath = [TYMapFileManager getMapDBPath];
    TYMapDBAdapter *db = [[TYMapDBAdapter alloc] initWithPath:dbPath];
    [db open];
    TYBuilding *resultBuilding = [db getBuilding:buildingID inCity:city];
    [db close];
    return resultBuilding;
}



@end
