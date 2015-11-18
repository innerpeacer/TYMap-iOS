//
//  TYGeos2AgsConverter.m
//  MapProject
//
//  Created by innerpeacer on 15/11/18.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYGeos2AgsConverter.h"

static AGSSpatialReference *spatialReference = [AGSSpatialReference spatialReferenceWithWKID:3395];

@implementation TYGeos2AgsConverter

+ (AGSGeometry *)agsGeometryFromGeosGeometry:(geos::geom::Geometry *)geometry
{
    switch (geometry->getGeometryTypeId()) {
        case GEOS_POINT:
            return [TYGeos2AgsConverter agsPointFromGeosPoint:dynamic_cast<geos::geom::Point *>(geometry)];
            break;
            
        case GEOS_MULTIPOINT:
            return [TYGeos2AgsConverter agsMultiPointFromGeosMultiPoint:dynamic_cast<geos::geom::MultiPoint *>(geometry)];
            break;
            
        case GEOS_LINESTRING:
            return [TYGeos2AgsConverter agsPolylineFromGeosLineString:dynamic_cast<geos::geom::LineString *>(geometry)];
            break;
            
        case GEOS_LINEARRING:
            return [TYGeos2AgsConverter agsPolylineFromGeosLinearRing:dynamic_cast<geos::geom::LinearRing *>(geometry)];
            break;
            
        case GEOS_MULTILINESTRING:
            return [TYGeos2AgsConverter agsPolylineFromGeosMultiLineString:dynamic_cast<geos::geom::MultiLineString *>(geometry)];
            break;
            
        case GEOS_POLYGON:
            return [TYGeos2AgsConverter agsPolygonFromGeosPolygon:dynamic_cast<geos::geom::Polygon *>(geometry)];
            break;
            
        case GEOS_MULTIPOLYGON:
            return [TYGeos2AgsConverter agsPolygonFromGeosMultiPolygon:dynamic_cast<geos::geom::MultiPolygon *>(geometry)];
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
        geos::geom::Coordinate c = ls->getCoordinateN(i);
        [polyline addPointToPath:[AGSPoint pointWithX:c.x y:c.y spatialReference:spatialReference]];
    }
    return polyline;
}

+ (AGSPolyline *)agsPolylineFromGeosLinearRing:(geos::geom::LinearRing *)lr
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    for (int i = 0; i < lr->getNumPoints(); i++) {
        geos::geom::Coordinate c = lr->getCoordinateN(i);
        [polyline addPointToPath:[AGSPoint pointWithX:c.x y:c.y spatialReference:spatialReference]];
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
            geos::geom::Coordinate c = simpleLinestring->getCoordinateN(i);
            [polyline addPointToPath:[AGSPoint pointWithX:c.x y:c.y spatialReference:spatialReference]];
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
            geos::geom::Coordinate c = exteriorRing->getCoordinateN(i);
            [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
        }
    }
    
    for (int j = 0; j < p->getNumInteriorRing(); ++j) {
        const LineString *interiorRing = p->getInteriorRingN(j);
        [polygon addRingToPolygon];
        for (int k = 0; k < interiorRing->getNumPoints(); ++k) {
            geos::geom::Coordinate c = interiorRing->getCoordinateN(k);
            [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
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
                geos::geom::Coordinate c = exteriorRing->getCoordinateN(i);
                [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
            }
        }
        
        for (int j = 0; j < simplePolygon->getNumInteriorRing(); ++j) {
            const LineString *interiorRing = simplePolygon->getInteriorRingN(j);
            [polygon addRingToPolygon];
            for (int k = 0; k < interiorRing->getNumPoints(); ++k) {
                geos::geom::Coordinate c = interiorRing->getCoordinateN(k);
                [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
            }
        }
    }
    return polygon;
}

@end
