//
//  TYParkingLayer.m
//  MapProject
//
//  Created by innerpeacer on 15/11/8.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPParkingLayer.h"

@interface IPParkingLayer()
{
    UIColor *occupiedColor;
    UIColor *availableColor;
    
    AGSSimpleFillSymbol *occupiedFillSymbol;
    AGSSimpleFillSymbol *availableFillSymbol;
}

@end

@implementation IPParkingLayer

- (id)initWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        occupiedColor = [UIColor redColor];
        availableColor = [UIColor greenColor];
        
        occupiedFillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:occupiedColor outlineColor:[UIColor whiteColor]];
        availableFillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:availableColor outlineColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setOccupiedParkingColor:(UIColor *)color
{
    occupiedColor = color;
    occupiedFillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:occupiedColor outlineColor:[UIColor whiteColor]];

}

- (void)setAvailableParkingColor:(UIColor *)color
{
    availableColor = color;
    availableFillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:availableColor outlineColor:[UIColor whiteColor]];
}

- (AGSSimpleFillSymbol *)getOccupiedParkingSymbol
{
    return occupiedFillSymbol;
}

- (AGSSimpleFillSymbol *)getAvailableParkingSymbol
{
    return availableFillSymbol;
}


@end
