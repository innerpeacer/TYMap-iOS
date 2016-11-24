//
//  TYMapCoordConverter.m
//  BRT-RTMap
//
//  Created by innerpeacer on 2016/10/10.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "TYMapCoordConverter.h"

@interface TYCoordTransform : NSObject
- (id)initWithTYCoords:(NSArray *)tyCoordArray ThirdCoords:(NSArray *)thirdCoordArray;
- (NSArray *)TYMapToThirdMap:(NSArray *)array;
@end


@interface TYMapCoordConverter()
{
    NSMutableDictionary *transformDict;
}

@end

@implementation TYMapCoordConverter

- (id)initWithTranformFile:(NSString *)path
{
    self = [super init];
    if (self) {
        transformDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *floorDict = [NSMutableDictionary dictionary];
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSError *error = nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            array = [NSArray array];
        }
        
        for (NSDictionary *dict in array) {
            NSNumber *floorNumber = dict[@"tyfloor"];
            NSArray *tyCoords = dict[@"tyCoords"];
            
            NSString *thirdFloor = dict[@"thirdfloor"];
            NSArray *thirdCoords = dict[@"thirdCoords"];
                        
            TYCoordTransform *transform = [[TYCoordTransform alloc] initWithTYCoords:tyCoords ThirdCoords:thirdCoords];
            [transformDict setObject:transform forKey:floorNumber];
            [floorDict setObject:thirdFloor forKey:floorNumber];
        }
        self.floorMap = [NSDictionary dictionaryWithDictionary:floorDict];
    }
    return self;
}

- (NSArray *)getTransformedDataFromTYMap:(NSArray *)tyData;
{
    NSAssert((tyData && tyData.count == 3), @"The Input Coords for Transform is invalid!");
    NSNumber *floorNumber = tyData[2];
    TYCoordTransform *transform = transformDict[floorNumber];
    if (transform == nil) {
        return tyData;
    }
    
    NSArray *thirdCoord = [transform TYMapToThirdMap:@[tyData[0], tyData[1]]];
    return @[thirdCoord[0], thirdCoord[1], self.floorMap[floorNumber]];
}

@end

@interface TYCoordTransform()
{
    double tyCoords[6];
    double tyDelta[4];
    
    double thirdCoords[6];
    double thirdDelta[4];
}
@end

@implementation TYCoordTransform

- (id)initWithTYCoords:(NSArray *)tyCoordArray ThirdCoords:(NSArray *)thirdCoordArray
{
    self = [super init];
    if (self) {
        NSAssert((tyCoordArray && tyCoordArray.count == 6 && thirdCoordArray && thirdCoordArray.count == 6), @"The Coords for Transform is invalid!");
        for (int i = 0; i < 6; ++i) {
            tyCoords[i] = [tyCoordArray[i] doubleValue];
            thirdCoords[i] = [thirdCoordArray[i] doubleValue];
        }
        
        thirdDelta[0] = (thirdCoords[2] - thirdCoords[0]);
        thirdDelta[1] = (thirdCoords[3] - thirdCoords[1]);
        thirdDelta[2] = (thirdCoords[4] - thirdCoords[0]);
        thirdDelta[3] = (thirdCoords[5] - thirdCoords[1]);

        tyDelta[0] = (tyCoords[2] - tyCoords[0]);
        tyDelta[1] = (tyCoords[3] - tyCoords[1]);
        tyDelta[2] = (tyCoords[4] - tyCoords[0]);
        tyDelta[3] = (tyCoords[5] - tyCoords[1]);
    }
    return self;
}


- (NSArray *)TYMapToThirdMap:(NSArray *)array
{
    double ty_x = [array[0] doubleValue];
    double ty_y = [array[1] doubleValue];
    double delta_x = [self getTYDeltaX:ty_x];
    double delta_y = [self getTYDeltaY:ty_y];
    
    double lamda = (delta_x * tyDelta[3] - delta_y * tyDelta[2]) / (tyDelta[0] * tyDelta[3] - tyDelta[1] * tyDelta[2]);
    double miu = (delta_x * tyDelta[1] - delta_y * tyDelta[0]) / (tyDelta[2] * tyDelta[1] - tyDelta[0] * tyDelta[3]);
    
    double third_x = thirdCoords[0] + lamda * thirdDelta[0] + miu * thirdDelta[2];
    double third_y = thirdCoords[1] + lamda * thirdDelta[1] + miu * thirdDelta[3];
    return @[@(third_x), @(third_y)];
}

//- (NSArray *)ThirdMapToTYMap:(NSArray *)array
//{
//    double third_x = [array[0] doubleValue];
//    double third_y = [array[1] doubleValue];
//    double delta_x = [self getThirdDeltaX:third_x];
//    double delta_y = [self getThirdDeltaY:third_y];
//
//    double lamda = (delta_x * thirdDelta[3] - delta_y * thirdDelta[2]) / (thirdDelta[0] * thirdDelta[3] - thirdDelta[1] * thirdDelta[2]);
//    double miu = (delta_x * thirdDelta[1] - delta_y * thirdDelta[0]) / (thirdDelta[2] * thirdDelta[1] - thirdDelta[0] * thirdDelta[3]);
//
//    double ty_x = tyCoords[0] + lamda * tyDelta[0] + miu * tyDelta[2];
//    double ty_y = tyCoords[1] + lamda * tyDelta[1] + miu * tyDelta[3];
//    return @[@(ty_x), @(ty_y)];
//}

- (double)getTYDeltaX:(double)x
{
    return (x - tyCoords[0]);
}

- (double)getTYDeltaY:(double)y
{
    return (y - tyCoords[1]);
}

//- (double)getThirdDeltaX:(double)x
//{
//    return (x - thirdCoords[0]);
//}
//
//- (double)getThirdDeltaY:(double)y
//{
//    return (y - thirdCoords[1]);
//}

@end
