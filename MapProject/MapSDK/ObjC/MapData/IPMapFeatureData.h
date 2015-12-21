//
//  IPMapFeatureData.h
//  MapProject
//
//  Created by innerpeacer on 15/10/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface IPMapFeatureData : NSObject

- (id)initWithBuilding:(TYBuilding *)building;

//- (NSArray *)getAllMapData;
- (NSDictionary *)getAllMapDataOnFloor:(int)floor;
//- (NSArray *)getAllMapDataInLayer:(int)layer;
//- (NSArray *)getAllMapDataOnFloor:(int)floor InLayer:(int)layer;

@end
