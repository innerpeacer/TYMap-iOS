//
//  ShpRouteDBRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

#include <geos.h>
#include <geos/geom.h>

@interface ShpRouteDBRecord : NSObject

@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, assign) int geometryID;
@property (nonatomic, assign) BOOL oneWay;

- (geos::geom::Geometry *)getGeosGeometry;
- (AGSGeometry *)getAgsGeometry;

@end
