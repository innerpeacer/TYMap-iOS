//
//  TYDirectionalString.m
//  MapProject
//
//  Created by innerpeacer on 15/5/5.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYDirectionalHint.h"
#import "Vector2.h"

#define DIRECTIONAL_STRING_STRAIGHT @"直行"
#define DIRECTIONAL_STRING_BACKWARD @"向后方"

#define DIRECTIONAL_STRING_TURN_RIGHT @"右转向前行进"
#define DIRECTIONAL_STRING_TURN_LEFT @"左转向前行进"
#define DIRECTIONAL_STRING_RIGHT_FORWARD @"向右前方行进"
#define DIRECTIONAL_STRING_LEFT_FORWARD @"向左前方行进"
#define DIRECTIONAL_STRING_RIGHT_BACKWARD @"向右后方行进"
#define DIRECTIONAL_STRING_LEFT_BACKWARD @"向左后方行进"

@interface TYDirectionalHint()
{
    Vector2 *vector;
}

@end


@implementation TYDirectionalHint

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

- (NSString *)getDirection:(TYRelativeDirection)direction
{
    NSString *result = nil;
    switch (direction) {
        case TYStraight:
            result = DIRECTIONAL_STRING_STRAIGHT;
            break;
            
        case TYTurnRight:
            result = DIRECTIONAL_STRING_TURN_RIGHT;
            break;
            
        case TYTurnLeft:
            result = DIRECTIONAL_STRING_TURN_LEFT;
            break;
            
        case TYLeftForward:
            result = DIRECTIONAL_STRING_LEFT_FORWARD;
            break;
            
        case TYLeftBackward:
            result = DIRECTIONAL_STRING_LEFT_BACKWARD;
            break;
            
        case TYRightForward:
            result = DIRECTIONAL_STRING_RIGHT_FORWARD;
            break;
            
        case TYRightBackward:
            result = DIRECTIONAL_STRING_RIGHT_BACKWARD;
            break;
            
        case TYBackward:
            result = DIRECTIONAL_STRING_BACKWARD;
            break;
    }
    return result;
}

- (TYRelativeDirection)calculateRelativeDirection:(double)angle previousAngle:(double)preAngle
{
    TYRelativeDirection direction;
    
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
        direction = TYStraight;
        return direction;
    }
    
    if (deltaAngle < -180 + BACKWARD_REFERENCE_ANGLE || deltaAngle > 180 - BACKWARD_REFERENCE_ANGLE) {
        direction = TYBackward;
    } else if (deltaAngle >= -180 + BACKWARD_REFERENCE_ANGLE && deltaAngle <= -90 - LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = TYLeftBackward;
    } else if (deltaAngle >= -90 - LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= -90 + LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = TYTurnLeft;
    } else if (deltaAngle >= -90 + LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= -FORWARD_REFERENCE_ANGLE) {
        direction = TYLeftForward;
    } else if (deltaAngle >= -FORWARD_REFERENCE_ANGLE && deltaAngle <= FORWARD_REFERENCE_ANGLE) {
        direction = TYStraight;
    } else if (deltaAngle >= FORWARD_REFERENCE_ANGLE && deltaAngle <= 90 - LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = TYRightForward;
    } else if (deltaAngle >= 90 - LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= 90 + LEFT_RIGHT_REFERENCE_ANGLE) {
        direction = TYTurnRight;
    } else if (deltaAngle >= 90 + LEFT_RIGHT_REFERENCE_ANGLE && deltaAngle <= 180 - BACKWARD_REFERENCE_ANGLE) {
        direction = TYRightBackward;
    }
    
    return direction;
}

@end
