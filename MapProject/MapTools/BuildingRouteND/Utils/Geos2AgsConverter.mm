//
//  Geos2AgsConverter.m
//  OfflineRouteTask
//
//  Created by innerpeacer on 15/9/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "Geos2AgsConverter.h"

static AGSSpatialReference *spatialReference = [AGSSpatialReference spatialReferenceWithWKID:3395];

@implementation Geos2AgsConverter

+ (AGSGeometry *)agsgeometryFromGeosGeometry:(geos::geom::Geometry *)geometry
{
    switch (geometry->getGeometryTypeId()) {
        case GEOS_POINT:
            return [Geos2AgsConverter agsPointFromGeosPoint:dynamic_cast<geos::geom::Point *>(geometry)];
            break;
            
        case GEOS_MULTIPOINT:
            return [Geos2AgsConverter agsMultiPointFromGeosMultiPoint:dynamic_cast<geos::geom::MultiPoint *>(geometry)];
            break;
            
        case GEOS_LINESTRING:
            return [Geos2AgsConverter agsPolylineFromGeosLineString:dynamic_cast<geos::geom::LineString *>(geometry)];
            break;
            
        case GEOS_LINEARRING:
            return [Geos2AgsConverter agsPolylineFromGeosLinearRing:dynamic_cast<geos::geom::LinearRing *>(geometry)];
            break;
            
        case GEOS_MULTILINESTRING:
            return [Geos2AgsConverter agsPolylineFromGeosMultiLineString:dynamic_cast<geos::geom::MultiLineString *>(geometry)];
            break;

        case GEOS_POLYGON:
            return [Geos2AgsConverter agsPolygonFromGeosPolygon:dynamic_cast<geos::geom::Polygon *>(geometry)];
            break;

        case GEOS_MULTIPOLYGON:
            return [Geos2AgsConverter agsPolygonFromGeosMultiPolygon:dynamic_cast<geos::geom::MultiPolygon *>(geometry)];
            break;

        default:
            return nil;
            break;
    }
    return nil;
}

+ (AGSPoint *)agsPointFromGeosPoint:(geos::geom::Point *)p
{
    return [AGSPoint pointWithX:p->getX() y:p->getY() spatialReference:spatialReference];
}

+ (AGSMultipoint *)agsMultiPointFromGeosMultiPoint:(geos::geom::MultiPoint *)mp
{
    AGSMutableMultipoint *multiPoint = [[AGSMutableMultipoint alloc] init];
    for (int i = 0; i < mp->getNumGeometries(); ++i) {
        const geos::geom::Point *simplePoint = dynamic_cast<const geos::geom::Point *>(mp->getGeometryN(i));
        [multiPoint addPoint:[AGSPoint pointWithX:simplePoint->getX() y:simplePoint->getY() spatialReference:spatialReference]];
    }
    return multiPoint;
}

+ (AGSPolyline *)agsPolylineFromGeosLineString:(geos::geom::LineString *)ls
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    for (int i = 0; i < ls->getNumPoints(); i++) {
        geos::geom::Point *point = ls->getPointN(i);
        [polyline addPointToPath:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:spatialReference]];
    }
    return polyline;
}

+ (AGSPolyline *)agsPolylineFromGeosLinearRing:(geos::geom::LinearRing *)lr
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    for (int i = 0; i < lr->getNumPoints(); i++) {
        geos::geom::Point *point = lr->getPointN(i);
        [polyline addPointToPath:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:spatialReference]];
    }
    return polyline;
}

+ (AGSPolyline *)agsPolylineFromGeosMultiLineString:(geos::geom::MultiLineString *)ms
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    for (int i = 0; i < ms->getNumGeometries(); ++i) {
        const LineString *simpleLinestring = dynamic_cast<const LineString *>(ms->getGeometryN(i));
        [polyline addPathToPolyline];
        for (int i = 0; i < simpleLinestring->getNumPoints(); i++) {
            geos::geom::Point *point = simpleLinestring->getPointN(i);
            [polyline addPointToPath:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:nil]];
        }
    }
    return polyline;
}

+ (AGSPolygon *)agsPolygonFromGeosPolygon:(geos::geom::Polygon *)p
{
    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] init];
    const LineString *exteriorRing = p->getExteriorRing();
    if (exteriorRing) {
        [polygon addRingToPolygon];
        for (int i = 0; i < exteriorRing->getNumPoints(); ++i) {
            geos::geom::Point *point = exteriorRing->getPointN(i);
            [polygon addPointToRing:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:nil]];
            delete point;
        }
    }
    
    for (int j = 0; j < p->getNumInteriorRing(); ++j) {
        const LineString *interiorRing = p->getInteriorRingN(j);
        [polygon addRingToPolygon];
        for (int k = 0; k < interiorRing->getNumPoints(); ++k) {
            geos::geom::Point *point = interiorRing->getPointN(k);
            [polygon addPointToRing:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:nil]];
            delete point;
        }
    }
    return polygon;
}


+ (AGSPolygon *)agsPolygonFromGeosMultiPolygon:(geos::geom::MultiPolygon *)p
{
    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] init];
    
    for (int i = 0; i < p->getNumGeometries(); ++i) {
        const Polygon *simplePolygon = dynamic_cast<const Polygon *>(p->getGeometryN(i));
        
        const LineString *exteriorRing = simplePolygon->getExteriorRing();
        if (exteriorRing) {
            [polygon addRingToPolygon];
            for (int i = 0; i < exteriorRing->getNumPoints(); ++i) {
                geos::geom::Point *point = exteriorRing->getPointN(i);
                [polygon addPointToRing:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:nil]];
            }
        }
        
        for (int j = 0; j < simplePolygon->getNumInteriorRing(); ++j) {
            const LineString *interiorRing = simplePolygon->getInteriorRingN(j);
            [polygon addRingToPolygon];
            for (int k = 0; k < interiorRing->getNumPoints(); ++k) {
                geos::geom::Point *point = interiorRing->getPointN(k);
                [polygon addPointToRing:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:nil]];
            }
        }
    }
    return polygon;
}

@end
