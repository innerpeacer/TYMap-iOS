//
//  NPDirectionalString.m
//  MapProject
//
//  Created by innerpeacer on 15/5/5.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPDirectionalHint.h"
#import "Vector2.h"

#define DIRECTIONAL_STRING_STRAIGHT @"直行"
#define DIRECTIONAL_STRING_BACKWARD @"向后方"

#define DIRECTIONAL_STRING_TURN_RIGHT @"右转向前行进"
#define DIRECTIONAL_STRING_TURN_LEFT @"左转向前行进"
#define DIRECTIONAL_STRING_RIGHT_FORWARD @"向右前方行进"
#define DIRECTIONAL_STRING_LEFT_FORWARD @"向左前方行进"
#define DIRECTIONAL_STRING_RIGHT_BACKWARD @"向右后方行进"
#define DIRECTIONAL_STRING_LEFT_BACKWARD @"向左后方行进"

@interface NPDirectionalHint()
{
    Vector2 *vector;
}

@end


@implementation NPDirectionalHint

- (id)initWithStartPoint:(AGSPoint *)start EndPoint:(AGSPoint *)end PreviousAngle:(double)angle
{
    if (self) {
        _startPoint = start;
        _endPoint = end;
        
        vector = [[Vector2 alloc] init];
        vector.x = _endPoint.x - _startPoint.x;
        vector.y = _endPoint.y - _startPoint.y;
        
        _length = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:_startPoint toGeometry:_endPoint];
        
        _currentAngle = [vector getAngle];
        _previousAngle = angle;
        
        _relativeDirection = [self calculateRelativeDirection:_currentAngle previousAngle:_previousAngle];
    }
    return self;
}

- (NSString *)getDirectionString
{
//    NSMutableString *result = [NSMutableString string];
//    if (_landMark) {
//        [result appendFormat:@"在 %@ 附近",_landMark.name];
//    }
//
//    [result appendFormat:@"%@ %.0fm", [self getDirection:_relativeDirection], _length];
//    return result;
    return [NSString stringWithFormat:@"%@ %.0fm", [self getDirection:_relativeDirection], _length];
}

- (NSString *)getLandMarkString
{
    NSString *result = nil;
    if (_landMark) {
        result = [NSString stringWithFormat:@"在 %@ 附近",_landMark.name];;
    }
    return result;
}

- (BOOL)hasLandMark
{
    if (_landMark) {
        return YES;
    }
    
    return NO;
}

- (NSString *)getDirection:(NPRelativeDirection)direction
{
    NSString *result = nil;
    switch (direction) {
        case NPStraight:
            result = DIRECTIONAL_STRING_STRAIGHT;
            break;
            
        case NPTurnRight:
            result = DIRECTIONAL_STRING_TURN_RIGHT;
            break;
            
        case NPTurnLeft:
            result = DIRECTIONAL_STRING_TURN_LEFT;
            break;
            
        case NPLeftForward:
            result = DIRECTIONAL_STRING_LEFT_FORWARD;
            break;
            
        case NPLeftBackward:
            result = DIRECTIONAL_STRING_LEFT_BACKWARD;
            break;
            
        case NPRightForward:
            result = DIRECTIONAL_STRING_RIGHT_FORWARD;
            break;
            
        case NPRightBackward:
            result = DIRECTIONAL_STRING_RIGHT_BACKWARD;
            break;
            
        case NPBackward:
            result = DIRECTIONAL_STRING_BACKWARD;
            break;
    }
    return result;
}

- (NPRelativeDirection)calculateRelativeDirection:(double)angle previousAngle:(double)preAngle
{
    NPRelativeDirection direction;
    
    double deltaAngle = angle - preAngle;
    
    if (deltaAngle >=180) {
        deltaAngle -= 360;
    }
    
    if (deltaAngle <= -180) {
        deltaAngle += 360;
    }
    
#define FORWARD_REFERENCE_ANGLE 30
#define BACKWARD_REFERENCE_ANGLE 10
#define LEFT_RIGHT_REFERENCE_ANGLE 30
    
    if (preAngle == INITIAL_EMPTY_ANGLE) {
        direction = NPStraight;
        return direction;
    }
    
    if (deltaAngle < -180 + BACKWARD_REFERENCE_ANGLE || deltaAngle > 180 - BACKWARD_REFERENCE_ANGLE) {
        direction = NPBackward;
    } else if (deltaAngle >= -180 + BACKWARD_REFERENCE_ANGLE && deltaAngle <= -90 - LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = NPLeftBackward;
    } else if (deltaAngle >= -90 - LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= -90 + LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = NPTurnLeft;
    } else if (deltaAngle >= -90 + LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= -FORWARD_REFERENCE_ANGLE) {
        direction = NPLeftForward;
    } else if (deltaAngle >= -FORWARD_REFERENCE_ANGLE && deltaAngle <= FORWARD_REFERENCE_ANGLE) {
        direction = NPStraight;
    } else if (deltaAngle >= FORWARD_REFERENCE_ANGLE && deltaAngle <= 90 - LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = NPRightForward;
    } else if (deltaAngle >= 90 - LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= 90 + LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = NPTurnRight;
    } else if (deltaAngle >= 90 + LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= 180 - BACKWARD_REFERENCE_ANGLE) {
        direction = NPRightBackward;
    }
    
    return direction;
}

@end
