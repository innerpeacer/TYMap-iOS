//
//  TYSyncMapDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYSyncMapDBAdapter.h"
#import "TYMapDBConstants.h"
#import <sqlite3.h>

@interface TYSyncMapDBAdapter()
{
    sqlite3 *_database;
    NSString *_dbPath;
}

@end

@implementation TYSyncMapDBAdapter

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _dbPath = path;
    }
    return self;
}

- (BOOL)eraseCityTable
{
    NSString *errorString = @"Error: failed to erase City Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_CITY];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)eraseBuildingTable
{
    NSString *errorString = @"Error: failed to erase Building Table";
    NSString *sql = [NSString stringWithFormat:@"delete from %@", TABLE_BUILDING];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)insertCity:(TYCity *)city
{
    NSString *errorString = @"Error: failed to insert city into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?)", TABLE_CITY, FIELD_CITY_1_ID, FIELD_CITY_2_NAME, FIELD_CITY_3_SNAME, FIELD_CITY_4_LONGITUDE, FIELD_CITY_5_LATITUDE, FIELD_CITY_6_STATUS];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [city.cityID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [city.name UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [city.sname UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 4, city.longitude);
    sqlite3_bind_double(statement, 5, city.latitude);
    sqlite3_bind_int(statement, 6, city.status);

    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (int)insertCities:(NSArray *)cities
{
    int count = 0;
    for (TYCity *city in cities) {
       BOOL success = [self insertCity:city];
        if (success) {
            count++;
        }
    }
    return count;
}

- (BOOL)insertBuilding:(TYBuilding *)building
{
    NSString *errorString = @"Error: failed to insert building into the database.";
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", TABLE_BUILDING, FIELD_BUILDING_1_CITY_ID, FIELD_BUILDING_2_ID, FIELD_BUILDING_3_NAME, FIELD_BUILDING_4_LONGITUDE, FIELD_BUILDING_5_LATITUDE, FIELD_BUILDING_6_ADDRESS, FIELD_BUILDING_7_INIT_ANGLE, FIELD_BUILDING_8_ROUTE_URL, FIELD_BUILDING_9_OFFSET_X, FIELD_BUILDING_10_OFFSET_Y, FIELD_BUILDING_11_STATUS];
    sqlite3_stmt *statement;
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [building.cityID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [building.buildingID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [building.name UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 4, building.longitude);
    sqlite3_bind_double(statement, 5, building.latitude);
    sqlite3_bind_text(statement, 6, [building.address UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 7, building.initAngle);
    sqlite3_bind_text(statement, 8, [building.routeURL UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 9, building.offset.x);
    sqlite3_bind_double(statement, 10, building.offset.y);
    sqlite3_bind_int(statement, 11, building.status);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (int)insertBuildings:(NSArray *)buildings
{
    int count = 0;
    for (TYBuilding *building in buildings) {
        BOOL success = [self insertBuilding:building];
        if (success) {
            count++;
        }
    }
    return count;
}

- (BOOL)updateCity:(TYCity *)city
{
    NSString *errorString = @"Error: failed to update City";
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@=?, %@=?, %@=?, %@=?, %@=?, %@=? where %@=?", TABLE_CITY, FIELD_CITY_1_ID, FIELD_CITY_2_NAME, FIELD_CITY_3_SNAME, FIELD_CITY_4_LONGITUDE, FIELD_CITY_5_LATITUDE, FIELD_CITY_6_STATUS, FIELD_CITY_1_ID];
//    NSLog(@"%@", sql);
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }

    sqlite3_bind_text(statement, 1, [city.cityID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [city.name UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [city.sname UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 4, city.longitude);
    sqlite3_bind_double(statement, 5, city.latitude);
    sqlite3_bind_int(statement, 6, city.status);
    sqlite3_bind_text(statement, 7, [city.cityID UTF8String], -1, SQLITE_STATIC);

    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (void)updateCities:(NSArray *)cities
{
    for (TYCity *city in cities) {
        [self updateCity:city];
    }
}

- (BOOL)updateBuilding:(TYBuilding *)building
{
    NSString *errorString = @"Error: failed to update building";
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=? where %@=?", TABLE_BUILDING, FIELD_BUILDING_1_CITY_ID, FIELD_BUILDING_2_ID, FIELD_BUILDING_3_NAME, FIELD_BUILDING_4_LONGITUDE, FIELD_BUILDING_5_LATITUDE, FIELD_BUILDING_6_ADDRESS, FIELD_BUILDING_7_INIT_ANGLE, FIELD_BUILDING_8_ROUTE_URL, FIELD_BUILDING_9_OFFSET_X, FIELD_BUILDING_10_OFFSET_Y, FIELD_BUILDING_11_STATUS, FIELD_BUILDING_2_ID];
    //    NSLog(@"%@", sql);
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [building.cityID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [building.buildingID UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [building.name UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 4, building.longitude);
    sqlite3_bind_double(statement, 5, building.latitude);
    sqlite3_bind_text(statement, 6, [building.address UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 7, building.initAngle);
    sqlite3_bind_text(statement, 8, [building.routeURL UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_double(statement, 9, building.offset.x);
    sqlite3_bind_double(statement, 10, building.offset.y);
    sqlite3_bind_int(statement, 11, building.status);
    sqlite3_bind_text(statement, 12, [building.buildingID UTF8String], -1, SQLITE_STATIC);

    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (void)updateBuildings:(NSArray *)buildings
{
    for (TYBuilding *building in buildings) {
        [self updateBuilding:building];
    }
}

- (BOOL)deleteCity:(NSString *)cityID
{
    NSString *errorString = @"Error: failed to delete City";
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", TABLE_CITY, FIELD_CITY_1_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [cityID UTF8String], -1, SQLITE_STATIC);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
}

- (BOOL)deleteBuilding:(NSString *)buildingID
{
    NSString *errorString = @"Error: failed to delete Building";
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", TABLE_BUILDING, FIELD_BUILDING_2_ID];
    sqlite3_stmt *statement;
    
    int success = sqlite3_prepare(_database, [sql UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"%@", errorString);
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [buildingID UTF8String], -1, SQLITE_STATIC);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"%@", errorString);
        return NO;
    }
    return YES;
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

- (void)createTablesIfNotExists
{
    {
        NSString *citySql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@) ", TABLE_CITY,
                             [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_CITY_0_PRIMARY_KEY],
                             [NSString stringWithFormat:@"%@ text not null", FIELD_CITY_1_ID],
                             [NSString stringWithFormat:@"%@ text not null", FIELD_CITY_2_NAME],
                             [NSString stringWithFormat:@"%@ text not null", FIELD_CITY_3_SNAME],
                             [NSString stringWithFormat:@"%@ real not null", FIELD_CITY_4_LONGITUDE],
                             [NSString stringWithFormat:@"%@ real not null", FIELD_CITY_5_LATITUDE],
                             [NSString stringWithFormat:@"%@ integer not null", FIELD_CITY_6_STATUS]];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [citySql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create city table failed!");
            return;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }

    {
         NSString *buildingSql = [NSString stringWithFormat:@"create table if not exists %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", TABLE_BUILDING,
                                  [NSString stringWithFormat:@"%@ integer primary key autoincrement", FIELD_BUILDING_0_PRIMARY_KEY],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_BUILDING_1_CITY_ID],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_BUILDING_2_ID],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_BUILDING_3_NAME],
                                  [NSString stringWithFormat:@"%@ real not null", FIELD_BUILDING_4_LONGITUDE],
                                  [NSString stringWithFormat:@"%@ real not null", FIELD_BUILDING_5_LATITUDE],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_BUILDING_6_ADDRESS],
                                  [NSString stringWithFormat:@"%@ real not null", FIELD_BUILDING_7_INIT_ANGLE],
                                  [NSString stringWithFormat:@"%@ text not null", FIELD_BUILDING_8_ROUTE_URL],
                                  [NSString stringWithFormat:@"%@ real not null", FIELD_BUILDING_9_OFFSET_X],
                                  [NSString stringWithFormat:@"%@ real not null", FIELD_BUILDING_10_OFFSET_Y],
                                  [NSString stringWithFormat:@"%@ integer not null", FIELD_BUILDING_11_STATUS]];
        sqlite3_stmt *statement;
        NSInteger sqlReturn = sqlite3_prepare_v2(_database, [buildingSql UTF8String], -1, &statement, nil);
        if (sqlReturn != SQLITE_OK) {
            NSLog(@"create building table failed!");
            return;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

- (BOOL)open
{
    if (sqlite3_open([_dbPath UTF8String], &_database) == SQLITE_OK) {
        //        NSLog(@"db open success!");
        [self createTablesIfNotExists];
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
