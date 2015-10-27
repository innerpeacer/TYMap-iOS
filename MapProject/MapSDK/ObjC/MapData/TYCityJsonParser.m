//
//  TYCityJsonParser.m
//  MapProject
//
//  Created by innerpeacer on 15/10/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYCityJsonParser.h"
#import "TYMapFileManager.h"

#define KEY_CITIES @"Cities"
#define KEY_CITY_ID @"id"
#define KEY_CITY_NAME @"name"
#define KEY_CITY_SHORT_NAME @"sname"
#define KEY_CITY_LONGITUDE @"longitude"
#define KEY_CITY_LATITUDE @"latitude"
#define KEY_CITY_STATUS @"status"

@implementation TYCityJsonParser

+ (NSArray *)parseAllCities
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];

    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getCityJsonPath];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *cityDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];

    NSArray *cityArray = [cityDict objectForKey:KEY_CITIES];
    for (NSDictionary *dict in cityArray) {
        NSString *cid = [dict objectForKey:KEY_CITY_ID];
        NSString *name = [dict objectForKey:KEY_CITY_NAME];
        NSString *sname = [dict objectForKey:KEY_CITY_SHORT_NAME];
        NSNumber *lonNumber = [dict objectForKey:KEY_CITY_LONGITUDE];
        NSNumber *latNumber = [dict objectForKey:KEY_CITY_LATITUDE];
        NSNumber *satNumber = [dict objectForKey:KEY_CITY_STATUS];

        TYCity *city = [[TYCity alloc] initWithCityID:cid Name:name SName:sname Lon:lonNumber.doubleValue Lat:latNumber.doubleValue];
        city.status = satNumber.intValue;
        [toReturn addObject:city];
    }
    return toReturn;
}

+ (NSArray *)parseAllCitiesFromFile:(NSString *)path
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *cityDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *cityArray = [cityDict objectForKey:KEY_CITIES];
    for (NSDictionary *dict in cityArray) {
        NSString *cid = [dict objectForKey:KEY_CITY_ID];
        NSString *name = [dict objectForKey:KEY_CITY_NAME];
        NSString *sname = [dict objectForKey:KEY_CITY_SHORT_NAME];
        NSNumber *lonNumber = [dict objectForKey:KEY_CITY_LONGITUDE];
        NSNumber *latNumber = [dict objectForKey:KEY_CITY_LATITUDE];
        NSNumber *satNumber = [dict objectForKey:KEY_CITY_STATUS];
        
        TYCity *city = [[TYCity alloc] initWithCityID:cid Name:name SName:sname Lon:lonNumber.doubleValue Lat:latNumber.doubleValue];
        city.status = satNumber.intValue;
        [toReturn addObject:city];
    }
    return toReturn;
}


+ (TYCity *)parseCity:(NSString *)cityID
{
    TYCity *city = nil;

    if (cityID == nil) {
        return city;
    }

    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getCityJsonPath];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *cityDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];

    NSArray *cityArray = [cityDict objectForKey:KEY_CITIES];
    for (NSDictionary *dict in cityArray) {
        NSString *cid = [dict objectForKey:KEY_CITY_ID];

        if ([cid isEqualToString:cityID]) {
            NSString *name = [dict objectForKey:KEY_CITY_NAME];
            NSString *sname = [dict objectForKey:KEY_CITY_SHORT_NAME];
            NSNumber *lonNumber = [dict objectForKey:KEY_CITY_LONGITUDE];
            NSNumber *latNumber = [dict objectForKey:KEY_CITY_LATITUDE];
            NSNumber *staNumber = [dict objectForKey:KEY_CITY_STATUS];

            city = [[TYCity alloc] initWithCityID:cid Name:name SName:sname Lon:lonNumber.doubleValue Lat:latNumber.doubleValue];
            city.status = staNumber.intValue;
            break;
        }
    }

    return city;
}

@end
