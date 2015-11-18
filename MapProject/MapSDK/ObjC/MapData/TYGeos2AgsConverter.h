//
//  TYGeos2AgsConverter.h
//  MapProject
//
//  Created by innerpeacer on 15/11/18.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <geos.h>
#include <geos/geom.h>
#import <ArcGIS/ArcGIS.h>

using namespace geos::geom;
@interface TYGeos2AgsConverter : NSObject

+ (AGSGeometry *)agsGeometryFromGeosGeometry:(geos::geom::Geometry *)geometry;

+ (AGSPoint *)agsPointFromGeosPoint:(geos::geom::Point *)p;
+ (AGSMultipoint *)agsMultiPointFromGeosMultiPoint:(geos::geom::MultiPoint *)mp;

+ (AGSPolyline *)agsPolylineFromGeosLineString:(geos::geom::LineString *)ls;
+ (AGSPolyline *)agsPolylineFromGeosLinearRing:(geos::geom::LinearRing *)lr;
+ (AGSPolyline *)agsPolylineFromGeosMultiLineString:(geos::geom::MultiLineString *)ms;

+ (AGSPolygon *)agsPolygonFromGeosPolygon:(geos::geom::Polygon *)p;
+ (AGSPolygon *)agsPolygonFromGeosMultiPolygon:(geos::geom::MultiPolygon *)p;

@end
