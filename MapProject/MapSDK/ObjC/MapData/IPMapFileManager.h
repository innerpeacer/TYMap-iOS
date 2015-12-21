//
//  IPMapFileManager.h
//  MapProject
//
//  Created by innerpeacer on 15/4/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapInfo.h"

@interface IPMapFileManager : NSObject

+ (NSString *)getMapDBPath;
+ (NSString *)getMapDataDBPath:(TYBuilding *)building;

+ (NSString *)getLandmarkJsonPath:(TYMapInfo *)info;
+ (NSString *)getBrandJsonPath:(TYBuilding *)building;
+ (NSString *)getPOIDBPath:(TYBuilding *)building;

+ (NSString *)getSymbolDBPath:(TYBuilding *)building;

@end
