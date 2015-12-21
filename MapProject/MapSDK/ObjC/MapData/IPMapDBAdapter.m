//
//  IPMapDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/10/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPMapDBAdapter.h"
#import "IPMapFileManager.h"
#import "IPMapDBConstants.h"

#import <sqlite3.h>

@interface IPMapDBAdapter()
{
    sqlite3 *_database;
    NSString *_dbPath;
}

@end

@implementation IPMapDBAdapter

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _dbPath = path;
    }
    return self;
}

- (NSArray *)getAllCities
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@, %@, %@ from %@", FIELD_CITY_1_ID, FIELD_CITY_2_NAME, FIELD_CITY_3_SNAME, FIELD_CITY_4_LONGITUDE, FIELD_CITY_5_LATITUDE, FIELD_CITY_6_STATUS, TABLE_CITY];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *cityName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *citySName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            double cityLongitude = sqlite3_column_double(statement, 3);
            double cityLatitude = sqlite3_column_double(statement, 4);
            int cityStatus =  sqlite3_column_int(statement, 5);
            
            TYCity *city = [[TYCity alloc] initWithCityID:cityID Name:cityName SName:citySName Lon:cityLatitude Lat:cityLongitude];
            city.status = cityStatus;
            
            [resultArray addObject:city];
        }
    }
    sqlite3_finalize(statement);
    return resultArray;
}

- (TYCity *)getCity:(NSString *)cityID
{
    TYCity *resultCity = nil;
    
    if (cityID == nil) {
        return resultCity;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@, %@, %@ from %@ ", FIELD_CITY_1_ID, FIELD_CITY_2_NAME, FIELD_CITY_3_SNAME, FIELD_CITY_4_LONGITUDE, FIELD_CITY_5_LATITUDE, FIELD_CITY_6_STATUS, TABLE_CITY];
    [sql appendFormat:@" where %@ = '%@' ", FIELD_CITY_1_ID, cityID];

    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *cityName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *citySName = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            double cityLongitude = sqlite3_column_double(statement, 3);
            double cityLatitude = sqlite3_column_double(statement, 4);
            int cityStatus =  sqlite3_column_int(statement, 5);
            
            resultCity = [[TYCity alloc] initWithCityID:cityID Name:cityName SName:citySName Lon:cityLatitude Lat:cityLongitude];
            resultCity.status = cityStatus;
        }
    }
    sqlite3_finalize(statement);
    return resultCity;
}

- (NSArray *)getAllBuildings:(TYCity *)city
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if (city == nil) {
        return resultArray;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@ ", FIELD_BUILDING_1_CITY_ID,  FIELD_BUILDING_2_ID,  FIELD_BUILDING_3_NAME,  FIELD_BUILDING_4_LONGITUDE,  FIELD_BUILDING_5_LATITUDE,  FIELD_BUILDING_6_ADDRESS,  FIELD_BUILDING_7_INIT_ANGLE,  FIELD_BUILDING_8_ROUTE_URL,  FIELD_BUILDING_9_OFFSET_X,  FIELD_BUILDING_10_OFFSET_Y,  FIELD_BUILDING_11_STATUS, TABLE_BUILDING];
    [sql appendFormat:@" where %@ = '%@' ", FIELD_BUILDING_1_CITY_ID, city.cityID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *buildingID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *name = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            double longitude = sqlite3_column_double(statement, 3);
            double latitude = sqlite3_column_double(statement, 4);
            NSString *address = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            double initAngle = sqlite3_column_double(statement, 6);
            NSString *routeURL = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            double offsetX = sqlite3_column_double(statement, 8);
            double offsetY = sqlite3_column_double(statement, 9);
            int status = sqlite3_column_int(statement, 10);
            
            OffsetSize offset;
            offset.x = offsetX;
            offset.y = offsetY;
            TYBuilding *building = [[TYBuilding alloc] initWithCityID:cityID BuildingID:buildingID Name:name Lon:longitude Lat:latitude Address:address InitAngle:initAngle RouteURL:routeURL Offset:offset];
            building.status = status;
            [resultArray addObject:building];
        }
    }
    sqlite3_finalize(statement);
    return resultArray;
}

- (TYBuilding *)getBuilding:(NSString *)buildingID inCity:(TYCity *)city
{
    TYBuilding *building = nil;
    
    if (buildingID == nil || city == nil) {
        return building;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@ ", FIELD_BUILDING_1_CITY_ID,  FIELD_BUILDING_2_ID,  FIELD_BUILDING_3_NAME,  FIELD_BUILDING_4_LONGITUDE,  FIELD_BUILDING_5_LATITUDE,  FIELD_BUILDING_6_ADDRESS,  FIELD_BUILDING_7_INIT_ANGLE,  FIELD_BUILDING_8_ROUTE_URL,  FIELD_BUILDING_9_OFFSET_X,  FIELD_BUILDING_10_OFFSET_Y,  FIELD_BUILDING_11_STATUS, TABLE_BUILDING];
    [sql appendFormat:@" where %@ = '%@' and %@ = '%@' ", FIELD_BUILDING_1_CITY_ID, city.cityID, FIELD_BUILDING_2_ID, buildingID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *cityID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *buildingID = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            NSString *name = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            double longitude = sqlite3_column_double(statement, 3);
            double latitude = sqlite3_column_double(statement, 4);
            NSString *address = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            double initAngle = sqlite3_column_double(statement, 6);
            NSString *routeURL = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            double offsetX = sqlite3_column_double(statement, 8);
            double offsetY = sqlite3_column_double(statement, 9);
            int status = sqlite3_column_int(statement, 10);
            
            OffsetSize offset;
            offset.x = offsetX;
            offset.y = offsetY;
            building = [[TYBuilding alloc] initWithCityID:cityID BuildingID:buildingID Name:name Lon:longitude Lat:latitude Address:address InitAngle:initAngle RouteURL:routeURL Offset:offset];
            building.status = status;
        }
    }
    sqlite3_finalize(statement);
    return building;
}

- (BOOL)open
{
    if (sqlite3_open([_dbPath UTF8String], &_database) == SQLITE_OK) {
        //        NSLog(@"db open success!");
        return YES;
    } else {
        //        NSLog(@"db open failed!");
        return NO;
    }
}

- (BOOL)close
{
    return (sqlite3_close(_database) == SQLITE_OK);
}
@end
