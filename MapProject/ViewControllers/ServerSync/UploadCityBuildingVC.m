//
//  UploadCityBuildingVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "UploadCityBuildingVC.h"
#import "TYCityManager.h"
#import "TYBuildingManager.h"

#import <MKNetworkKit/MKNetworkKit.h>

@interface UploadAllCityBuildingVC()
{
    NSArray *allCities;
    NSArray *allBuildings;
    
}

- (IBAction)uploadCitiesAndBuildings:(id)sender;
- (IBAction)getCitiesAndBuildings:(id)sender;
@end

@implementation UploadAllCityBuildingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    allCities = [TYCityManager parseAllCities];
    NSMutableArray *buildingArray = [NSMutableArray array];
    for (TYCity *city in allCities) {
        NSArray *buildings = [TYBuildingManager parseAllBuildings:city];
        [buildingArray addObjectsFromArray:buildings];
    }
    allBuildings = buildingArray;
}

- (void)uploadAllCities
{
    [self addToLog:@"uploadAllCities:"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:SUPER_USER_ID forKey:@"userID"];

    NSArray *cityArray = [self prepareCityArray];
    NSData *cityData = [NSJSONSerialization dataWithJSONObject:cityArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *cityString = [NSString stringWithCString:cityData.bytes encoding:NSUTF8StringEncoding];
    [param setValue:cityString forKey:@"cities"];
//    NSLog(@"%@", cityString);

    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:HOST_NAME];
    MKNetworkOperation *op = [engine operationWithPath:TY_API_UPLOAD_ALL_CITIES params:param httpMethod:@"POST"];
    
    [self addToLog:[NSString stringWithFormat:@"%@%@", HOST_NAME, TY_API_UPLOAD_ALL_CITIES]];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"ResponseData: %@", [operation responseString]);
        [self addToLog:@"Response String:"];
        [self addToLog:[operation responseString]];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
    [engine enqueueOperation:op];
    
}


- (void)uploadAllBuildings
{
    [self addToLog:@"uploadAllCities"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:SUPER_USER_ID forKey:@"userID"];
    
    NSArray *buildingArray = [self prepareBuildingArray];
    NSData *buildingData = [NSJSONSerialization dataWithJSONObject:buildingArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *buildingString = [NSString stringWithCString:buildingData.bytes encoding:NSUTF8StringEncoding];
    [param setValue:buildingString forKey:@"buildings"];
//    NSLog(@"%@", buildingString);

    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:HOST_NAME];
    MKNetworkOperation *op = [engine operationWithPath:TY_API_UPLOAD_ALL_BUILDINGS params:param httpMethod:@"POST"];
    
    [self addToLog:[NSString stringWithFormat:@"%@%@", HOST_NAME, TY_API_UPLOAD_ALL_BUILDINGS]];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"ResponseData: %@", [operation responseString]);
        [self addToLog:@"Response String:"];
        [self addToLog:[operation responseString]];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
    [engine enqueueOperation:op];
}

- (NSArray *)prepareCityArray
{
    NSMutableArray *cityArray = [NSMutableArray array];
    for (TYCity *city in allCities) {
        NSMutableDictionary *cityObject = [NSMutableDictionary dictionary];
        
        [cityObject setObject:city.cityID forKey:@"CITY_ID"];
        [cityObject setObject:city.name forKey:@"NAME"];
        [cityObject setObject:city.sname forKey:@"SNAME"];
        [cityObject setObject:@(city.longitude) forKey:@"LONGITUDE"];
        [cityObject setObject:@(city.latitude) forKey:@"LATITUDE"];
        [cityObject setObject:@(city.status) forKey:@"STATUS"];
        
        [cityArray addObject:cityObject];
    }
    return cityArray;
}

- (NSArray *)prepareBuildingArray
{
    NSMutableArray *buildingArray = [NSMutableArray array];
    for (TYBuilding *building in allBuildings) {
        NSMutableDictionary *buildingObject = [NSMutableDictionary dictionary];
        
        [buildingObject setObject:building.cityID forKey:@"CITY_ID"];
        [buildingObject setObject:building.buildingID forKey:@"BUILDING_ID"];
        [buildingObject setObject:building.name forKey:@"NAME"];
        
        [buildingObject setObject:@(building.longitude) forKey:@"LONGITUDE"];
        [buildingObject setObject:@(building.latitude) forKey:@"LATITUDE"];
        
        [buildingObject setObject:building.address forKey:@"ADDRESS"];
        [buildingObject setObject:@(building.initAngle) forKey:@"INIT_ANGLE"];
        [buildingObject setObject:building.routeURL forKey:@"ROUTE_URL"];

        [buildingObject setObject:@(building.offset.x) forKey:@"OFFSET_X"];
        [buildingObject setObject:@(building.offset.y) forKey:@"OFFSET_Y"];
        [buildingObject setObject:@(building.status) forKey:@"STATUS"];
        
        [buildingArray addObject:buildingObject];
    }
    return buildingArray;
}

- (IBAction)uploadCitiesAndBuildings:(id)sender {
    NSLog(@"uploadCitiesAndBuildings");
    [self uploadAllCities];
    [self uploadAllBuildings];
}

- (IBAction)getCitiesAndBuildings:(id)sender {
    NSLog(@"getCitiesAndBuildings");
}
@end