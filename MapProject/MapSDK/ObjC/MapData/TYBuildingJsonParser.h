//
//  TYBuildingJsonParser.h
//  MapProject
//
//  Created by innerpeacer on 15/10/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface TYBuildingJsonParser : NSObject

+ (TYBuilding *)parseBuilding:(NSString *)buildingID InCity:(TYCity *)city;
+ (NSArray *)parseAllBuildings:(TYCity *)city;
+ (NSArray *)parseAllBuildingsFromFile:(NSString *)path;

@end
