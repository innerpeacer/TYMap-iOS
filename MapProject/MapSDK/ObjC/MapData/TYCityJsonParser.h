//
//  TYCityJsonParser.h
//  MapProject
//
//  Created by innerpeacer on 15/10/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface TYCityJsonParser : NSObject

+ (NSArray *)parseAllCities;
+ (TYCity *)parseCity:(NSString *)cityID;

@end
