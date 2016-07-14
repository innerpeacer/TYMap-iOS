//
//  TYMapToFengMap.m
//  FMMapDemo
//
//  Created by innerpeacer on 16/6/16.
//  Copyright © 2016年 FengMap. All rights reserved.
//

#import "TYMapToFengMap.h"

#define FENG_MAP_X0 13522258.000000
#define FENG_MAP_Y0 3664066.000000
#define FENG_MAP_X1 13522298.000000
#define FENG_MAP_Y1 3664080.500000
#define FENG_MAP_X2 13522246.000000
#define FENG_MAP_Y2 3664098.250000

#define FENG_DELTA_1_X (FENG_MAP_X1 - FENG_MAP_X0)
#define FENG_DELTA_1_Y (FENG_MAP_Y1 - FENG_MAP_Y0)

#define FENG_DELTA_2_X (FENG_MAP_X2 - FENG_MAP_X0)
#define FENG_DELTA_2_Y (FENG_MAP_Y2 - FENG_MAP_Y0)

#define TY_MAP_X0 13523499.143225
#define TY_MAP_Y0 3642465.552261
#define TY_MAP_X1 13523509.682853
#define TY_MAP_Y1 3642465.582722
#define TY_MAP_X2 13523499.193993
#define TY_MAP_Y2 3642474.172823

#define TY_DELTA_1_X (TY_MAP_X1 - TY_MAP_X0)
#define TY_DELTA_1_Y (TY_MAP_Y1 - TY_MAP_Y0)

#define TY_DELTA_2_X (TY_MAP_X2 - TY_MAP_X0)
#define TY_DELTA_2_Y (TY_MAP_Y2 - TY_MAP_Y0)

@implementation TYMapToFengMap

//+ (NSArray *)FengMapToTYMap:(NSArray *)array
//{
//    double feng_x = [array[0] doubleValue];
//    double feng_y = [array[1] doubleValue];
//
//    double ty_x = TY_MAP_X0 + (TY_MAP_X1 - TY_MAP_X0) / (FENG_MAP_X1 - FENG_MAP_X0) * (feng_x - FENG_MAP_X0);
//    double ty_y = TY_MAP_Y0 + (TY_MAP_Y1 - TY_MAP_Y0) / (FENG_MAP_Y1 - FENG_MAP_Y0) * (feng_y - FENG_MAP_Y0);
//
//    return @[@(ty_x), @(ty_y)];
//}

+ (NSArray *)TYMapToFengMap:(NSArray *)array
{
    //    double ty_x = [array[0] doubleValue];
    //    double ty_y = [array[1] doubleValue];
    //
    //    double feng_x = FENG_MAP_X0 + (FENG_MAP_X1 - FENG_MAP_X0) / (TY_MAP_X1 - TY_MAP_X0) * (ty_x - TY_MAP_X0);
    //    double feng_y = FENG_MAP_Y0 + (FENG_MAP_Y1 - FENG_MAP_Y0) / (TY_MAP_Y1 - TY_MAP_Y0) * (ty_y - TY_MAP_Y0);
    //
    //    return @[@(feng_x), @(feng_y)];
    
    double ty_x = [array[0] doubleValue];
    double ty_y = [array[1] doubleValue];
    double delta_x = [TYMapToFengMap getTYDeltaX:ty_x];
    double delta_y = [TYMapToFengMap getTYDeltaY:ty_y];
    
    double lamda = (delta_x * TY_DELTA_2_Y - delta_y * TY_DELTA_2_X) / (TY_DELTA_1_X * TY_DELTA_2_Y - TY_DELTA_1_Y * TY_DELTA_2_X);
    double miu = (delta_x * TY_DELTA_1_Y - delta_y * TY_DELTA_1_X) / (TY_DELTA_2_X * TY_DELTA_1_Y - TY_DELTA_1_X * TY_DELTA_2_Y);
    
    double feng_x = FENG_MAP_X0 + lamda * FENG_DELTA_1_X + miu * FENG_DELTA_2_X;
    double feng_y = FENG_MAP_Y0 + lamda * FENG_DELTA_1_Y + miu * FENG_DELTA_2_Y;
    return @[@(feng_x), @(feng_y)];
}

+ (double)getTYDeltaX:(double)x
{
    return (x - TY_MAP_X0);
}

+ (double)getTYDeltaY:(double)y
{
    return (y - TY_MAP_Y0);
}


@end