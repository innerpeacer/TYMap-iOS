//
//  TYParkingLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/11/8.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface TYParkingLayer : AGSGraphicsLayer

- (void)setOccupiedParkingColor:(UIColor *)color;
- (void)setAvailableParkingColor:(UIColor *)color;

- (AGSSimpleFillSymbol *)getOccupiedParkingSymbol;
- (AGSSimpleFillSymbol *)getAvailableParkingSymbol;

@end
