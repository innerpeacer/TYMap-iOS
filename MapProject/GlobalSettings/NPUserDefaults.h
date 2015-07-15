//
//  NPUserDefaults.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYBuilding.h"
#import "TYCity.h"

@interface NPUserDefaults : NSObject

+ (void)setDefaultBuilding:(NSString *)buildingID;
+ (void)setDefaultCity:(NSString *)cityID;

+ (TYBuilding *)getDefaultBuilding;
+ (TYCity *)getDefaultCity;

@end
