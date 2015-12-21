//
//  TYLocationLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/2.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMapView.h"

@interface IPLocationLayer : AGSGraphicsLayer

- (void)setLocationSymbol:(AGSMarkerSymbol *)symbol;

- (void)updateDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(TYMapViewMode)mode;

- (void)showLocation:(AGSPoint *)location withDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(TYMapViewMode)mode;

- (void)removeLocation;

@end
