//
//  TYMapFileManager.h
//  MapProject
//
//  Created by innerpeacer on 15/4/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapInfo.h"

@interface TYMapFileManager : NSObject

+ (NSString *)getCityJsonPath;

+ (NSString *)getBuildingJsonPath:(NSString *)cityID;

+ (NSString *)getMapInfoJsonPath:(NSString *)cityID buildingID:(NSString *)buildingID;


+ (NSString *)getFloorLayerPath:(TYMapInfo *)info;
+ (NSString *)getRoomLayerPath:(TYMapInfo *)info;
+ (NSString *)getAssetLayerPath:(TYMapInfo *)info;
+ (NSString *)getFacilityLayerPath:(TYMapInfo *)info;
+ (NSString *)getLabelLayerPath:(TYMapInfo *)info;
+ (NSString *)getLandmarkJsonPath:(TYMapInfo *)info;

+ (NSString *)getBrandJsonPath:(TYBuilding *)building;

+ (NSString *)getRenderingScheme:(TYBuilding *)building;

+ (NSString *)getPOIDBPath:(TYBuilding *)building;

+ (NSString *)getPrimitiveDBPath:(TYBuilding *)building;

@end
