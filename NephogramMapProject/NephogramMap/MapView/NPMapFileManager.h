//
//  NPMapFileManager.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPMapInfo.h"

@interface NPMapFileManager : NSObject

+ (NSString *)getCityJsonPath;

+ (NSString *)getBuildingJsonPath:(NSString *)cityID;

+ (NSString *)getMapInfoJsonPath:(NSString *)cityID buildingID:(NSString *)buildingID;


+ (NSString *)getFloorLayerPath:(NPMapInfo *)info;
+ (NSString *)getRoomLayerPath:(NPMapInfo *)info;
+ (NSString *)getAssetLayerPath:(NPMapInfo *)info;
+ (NSString *)getFacilityLayerPath:(NPMapInfo *)info;
+ (NSString *)getLabelLayerPath:(NPMapInfo *)info;
+ (NSString *)getLandMarkJsonPath:(NPMapInfo *)info;

+ (NSString *)getRenderingScheme:(NPBuilding *)building;

+ (NSString *)getPOIDBPath:(NPBuilding *)building;

+ (NSString *)getPrimitiveDBPath:(NPBuilding *)building;


@end
