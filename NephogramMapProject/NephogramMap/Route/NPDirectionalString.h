//
//  NPDirectionalString.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/5.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "NPLandmark.h"

#define INITIAL_EMPTY_ANGLE 1000

typedef enum {
    NPStraight,
    NPTurnRight,
    NPRightForward,
    NPLeftForward,
    NPRightBackward,
    NPLeftBackward,
    NPTurnLeft,
    NPBackward
} NPRelativeDirection;

@interface NPDirectionalString : NSObject

- (id)initWithStartPoint:(AGSPoint *)start EndPoint:(AGSPoint *)end PreviousAngle:(double)angle;

@property (nonatomic, strong, readonly) AGSPoint *startPoint;
@property (nonatomic, strong, readonly) AGSPoint *endPoint;

@property (nonatomic, readonly) double previousAngle;
@property (nonatomic, readonly) double currentAngle;

@property (nonatomic, readonly) double length;

@property (nonatomic, strong) NPLandmark *landMark;

- (NSString *)getDirectionString;

@end