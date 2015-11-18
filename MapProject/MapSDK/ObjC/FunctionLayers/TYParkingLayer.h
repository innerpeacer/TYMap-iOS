//
//  TYParkingLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/11/8.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface TYParkingLayer : AGSGraphicsLayer

@property (nonatomic, strong) UIColor *ocuupiedColor;
@property (nonatomic, strong) UIColor *availableColor;

@end
