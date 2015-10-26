//
//  TYMapInfoDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/10/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>
#import "TYMapInfo.h"

@interface TYMapInfoDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (NSArray *)getAllMapInfos;
- (TYMapInfo *)getMapInfoWithName:(NSString *)floorName;
- (TYMapInfo *)getMapInfoWithMapID:(NSString *)mapID;
- (TYMapInfo *)getMapInfoWithFloor:(int)floor;

@end
