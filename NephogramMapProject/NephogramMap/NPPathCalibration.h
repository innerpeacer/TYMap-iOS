//
//  NPPathModifier.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/1.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface NPPathCalibration : NSObject

- (id)initWithFloorID:(NSString *)floorID;

- (AGSPoint *)calibrationPoint:(AGSPoint *)point;

- (void)setBufferWidth:(double)width;

@end