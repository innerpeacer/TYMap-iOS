//
//  NPUserDefaults.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPUserDefaults : NSObject

+ (void)setDefaultBuilding:(NSString *)buildingID;
+ (void)setDefaultCity:(NSString *)cityID;

+ (NSString *)getDefaultBuilding;
+ (NSString *)getDefaultCity;

@end
