//
//  TYLocationLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/2.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "TYMarkerSymbol.h"
#import "TYPoint.h"
#import "TYMapView.h"

@interface TYLocationLayer : AGSGraphicsLayer

- (void)setLocationSymbol:(TYMarkerSymbol *)symbol;

- (void)updateDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(TYMapViewMode)mode;

- (void)showLocation:(TYPoint *)location withDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(TYMapViewMode)mode;

- (void)removeLocation;

@end
