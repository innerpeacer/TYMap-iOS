//
//  TYUserDefaults.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

#define DEFAULT_MAP_ROOT @"MapResource"
#define DEFAULT_MAP_ENCRPTION_ROOT @"MapEncrypted"


@interface TYUserDefaults : NSObject

+ (void)setDefaultBuilding:(NSString *)buildingID;
+ (void)setDefaultCity:(NSString *)cityID;

+ (TYBuilding *)getDefaultBuilding;
+ (TYCity *)getDefaultCity;

@end
