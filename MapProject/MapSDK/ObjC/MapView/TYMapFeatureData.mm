//
//  TYMapFeatureData.m
//  MapProject
//
//  Created by innerpeacer on 15/10/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYMapFeatureData.h"
#import "IPXMapDataDBAdapter.hpp"
#import "TYMapFileManager.h"

#import "TYMapEnviroment.h"
#import <ArcGIS/ArcGIS.h>

using namespace Innerpeacer::MapSDK;
using namespace std;

@interface TYMapFeatureData()
{
    TYBuilding *building;
}

@end

@implementation TYMapFeatureData

- (id)initWithBuilding:(TYBuilding *)b
{
    self = [super init];
    if (self) {
        building = b;
    }
    return self;
}

- (NSDictionary *)getAllMapDataOnFloor:(int)floor
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    NSString *dbPath = [TYMapFileManager getMapDBPath:building];
    IPXMapDataDBAdapter *db = new IPXMapDataDBAdapter([dbPath UTF8String]);
    db->open();
    vector<IPXFeatureRecord *> allRecords = db->getAllRecordsOnFloor(floor);
    db->close();
    
    NSMutableArray *floorArray = [NSMutableArray array];
    NSMutableArray *roomArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    NSMutableArray *facilityArray = [NSMutableArray array];
    NSMutableArray *labelArray = [NSMutableArray array];

    for(vector<IPXFeatureRecord *>::iterator iter = allRecords.begin(); iter != allRecords.end(); ++iter) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:[NSString stringWithCString:(*iter)->geoID.c_str() encoding:NSUTF8StringEncoding] forKey:@"GEO_ID"];
        [attributes setObject:[NSString stringWithCString:(*iter)->poiID.c_str() encoding:NSUTF8StringEncoding] forKey:@"POI_ID"];
        [attributes setObject:[NSString stringWithCString:(*iter)->categoryID.c_str() encoding:NSUTF8StringEncoding] forKey:@"CATEGORY_ID"];
        [attributes setObject:@((*iter)->symbolID) forKey:@"COLOR"];

        if ((*iter)->name.length() > 0) {
            [attributes setObject:[NSString stringWithCString:(*iter)->name.c_str() encoding:NSUTF8StringEncoding] forKey:@"NAME"];
        }
        
        AGSGeometry *geometry = [TYMapFeatureData agsgeometryFromGeosGeometry:(*iter)->geometry];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:geometry symbol:nil attributes:attributes];
        switch ((*iter)->layer) {
            case 1:
                [floorArray addObject:graphic];
                break;
                
            case 2:
                [roomArray addObject:graphic];
                break;
            case 3:
                [assetArray addObject:graphic];
                break;
            
            case 4:
                [facilityArray addObject:graphic];
                break;
            
            case 5:
                [labelArray addObject:graphic];
                break;
                
            default:
                break;
        }
        
    }
    
    for(vector<IPXFeatureRecord *>::iterator iter = allRecords.begin(); iter != allRecords.end(); ++iter) {
        delete (*iter);
    }
    
    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:floorArray] forKey:@"floor"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:roomArray] forKey:@"room"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:assetArray] forKey:@"asset"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:facilityArray] forKey:@"facility"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:labelArray] forKey:@"label"];
    return resultDict;
}


+ (AGSGeometry *)agsgeometryFromGeosGeometry:(geos::geom::Geometry *)geometry
{
    switch (geometry->getGeometryTypeId()) {
        case GEOS_POINT:
            return [TYMapFeatureData agsPointFromGeosPoint:dynamic_cast<geos::geom::Point *>(geometry)];
            break;
            
        case GEOS_MULTIPOINT:
            return [TYMapFeatureData agsMultiPointFromGeosMultiPoint:dynamic_cast<geos::geom::MultiPoint *>(geometry)];
            break;
            
        case GEOS_LINESTRING:
            return [TYMapFeatureData agsPolylineFromGeosLineString:dynamic_cast<geos::geom::LineString *>(geometry)];
            break;
            
        case GEOS_LINEARRING:
            return [TYMapFeatureData agsPolylineFromGeosLinearRing:dynamic_cast<geos::geom::LinearRing *>(geometry)];
            break;
            
        case GEOS_MULTILINESTRING:
            return [TYMapFeatureData agsPolylineFromGeosMultiLineString:dynamic_cast<geos::geom::MultiLineString *>(geometry)];
            break;
            
        case GEOS_POLYGON:
            return [TYMapFeatureData agsPolygonFromGeosPolygon:dynamic_cast<geos::geom::Polygon *>(geometry)];
            break;
            
        case GEOS_MULTIPOLYGON:
            return [TYMapFeatureData agsPolygonFromGeosMultiPolygon:dynamic_cast<geos::geom::MultiPolygon *>(geometry)];
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}

+ (AGSPoint *)agsPointFromGeosPoint:(geos::geom::Point *)p
{
    return [AGSPoint pointWithX:p->getX() y:p->getY() spatialReference:[TYMapEnvironment defaultSpatialReference]];
}

+ (AGSMultipoint *)agsMultiPointFromGeosMultiPoint:(geos::geom::MultiPoint *)mp
{
    AGSMutableMultipoint *multiPoint = [[AGSMutableMultipoint alloc] init];
    for (int i = 0; i < mp->getNumGeometries(); ++i) {
        const geos::geom::Point *simplePoint = dynamic_cast<const geos::geom::Point *>(mp->getGeometryN(i));
        [multiPoint addPoint:[AGSPoint pointWithX:simplePoint->getX() y:simplePoint->getY() spatialReference:[TYMapEnvironment defaultSpatialReference]]];
    }
    return multiPoint;
}

+ (AGSPolyline *)agsPolylineFromGeosLineString:(geos::geom::LineString *)ls
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    for (int i = 0; i < ls->getNumPoints(); i++) {
        geos::geom::Point *point = ls->getPointN(i);
        [polyline addPointToPath:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:[TYMapEnvironment defaultSpatialReference]]];
    }
    return polyline;
}

+ (AGSPolyline *)agsPolylineFromGeosLinearRing:(geos::geom::LinearRing *)lr
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] init];
    [polyline addPathToPolyline];
    for (int i = 0; i < lr->getNumPoints(); i++) {
        geos::geom::Point *point = lr->getPointN(i);
        [polyline addPointToPath:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:[TYMapEnvironment defaultSpatialReference]]];
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
        }
    }
    
    for (int j = 0; j < p->getNumInteriorRing(); ++j) {
        const LineString *interiorRing = p->getInteriorRingN(j);
        [polygon addRingToPolygon];
        for (int k = 0; k < interiorRing->getNumPoints(); ++k) {
            geos::geom::Point *point = interiorRing->getPointN(k);
            [polygon addPointToRing:[AGSPoint pointWithX:point->getX() y:point->getY() spatialReference:nil]];
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
