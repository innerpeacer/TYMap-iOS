//
//  TYSyncMapDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface TYSyncMapDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (BOOL)eraseCityTable;
- (BOOL)insertCity:(TYCity *)city;
- (int)insertCities:(NSArray *)cities;
- (BOOL)updateCity:(TYCity *)city;
- (void)updateCities:(NSArray *)cities;
- (BOOL)deleteCity:(NSString *)cityID;
- (NSArray *)getAllCities;
- (TYCity *)getCity:(NSString *)cityID;

- (BOOL)eraseBuildingTable;
- (BOOL)insertBuilding:(TYBuilding *)building;
- (int)insertBuildings:(NSArray *)buildings;
- (BOOL)updateBuilding:(TYBuilding *)building;
- (void)updateBuildings:(NSArray *)buildings;
- (BOOL)deleteBuilding:(NSString *)buildingID;
- (NSArray *)getAllBuildings:(TYCity *)city;
- (TYBuilding *)getBuilding:(NSString *)buildingID inCity:(TYCity *)city;

@end
