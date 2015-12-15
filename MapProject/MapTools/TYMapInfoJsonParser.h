//
//  TYMapInfoJsonParser.h
//  MapProject
//
//  Created by innerpeacer on 15/10/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapInfo.h"
#import <TYMapData/TYMapData.h>

@interface TYMapInfoJsonParser : NSObject

+ (NSArray *)parseAllMapInfoFromFile:(NSString *)path;

@end
