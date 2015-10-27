//
//  TYMapDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/10/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface TYMapDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (NSArray *)getAllCities;
- (TYCity *)getCity:(NSString *)cityID;

- (NSArray *)getAllBuildings:(TYCity *)city;
- (TYBuilding *)getBuilding:(NSString *)buildingID inCity:(TYCity *)city;

@end