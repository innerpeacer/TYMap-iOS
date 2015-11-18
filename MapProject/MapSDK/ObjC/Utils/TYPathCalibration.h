//
//  TYPathCalibration.h
//  MapProject
//
//  Created by innerpeacer on 15/4/1.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"

@interface TYPathCalibration : NSObject

- (id)initWithMapInfo:(TYMapInfo *)mapInfo;
- (void)setBufferWidth:(double)width;

- (AGSPoint *)calibrationPoint:(AGSPoint *)point;


- (AGSPolyline *)getUnionPath;
- (AGSPolygon *)getUnionPolygon;
@end
