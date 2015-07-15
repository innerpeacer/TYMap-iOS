//
//  NPLocationLayer.h
//  MapProject
//
//  Created by innerpeacer on 15/4/2.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMarkerSymbol.h"
#import "NPPoint.h"
#import "NPMapView.h"

@interface NPLocationLayer : AGSGraphicsLayer

- (void)setLocationSymbol:(NPMarkerSymbol *)symbol;

- (void)updateDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(NPMapViewMode)mode;

- (void)showLocation:(NPPoint *)location withDeviceHeading:(double)deviceHeading initAngle:(double)initAngle mapViewMode:(NPMapViewMode)mode;

- (void)removeLocation;

@end
