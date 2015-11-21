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
    
    NSString *dbPath = [TYMapFileManager getMapDataDBPath:building];
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
        
        AGSGeometry *geometry = [TYMapFeatureData agsGeometryFromRecord:(*iter)];
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

+ (AGSGeometry *)agsGeometryFromRecord:(IPXFeatureRecord *)record
{
    switch (record->geometry->getGeometryTypeId()) {
        case geos::geom::GEOS_POINT:
            return [TYMapFeatureData agsPointFromGeosPointRecord:record];
            break;
            
        case geos::geom::GEOS_POLYGON:
            return [TYMapFeatureData agsPolygonFromGeosPolygonRecord:record];
            break;
            
        case geos::geom::GEOS_MULTIPOLYGON:
            return [TYMapFeatureData agsPolygonFromGeosMultiPolygonRecord:record];
            break;
            
        default:
            break;
    }
    return nil;
}

+ (AGSPolygon *)agsPolygonFromGeosMultiPolygonRecord:(IPXFeatureRecord *)record
{
    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] init];
    geos::geom::MultiPolygon *multiPolygon = record->getMultiPolygonIfSatisfied();

    for (int l = 0; l < multiPolygon->getNumGeometries(); ++l) {
        const geos::geom::Polygon *geosPolygon = getPolygonN(multiPolygon, l);

        const LineString *exteriorRing = geosPolygon->getExteriorRing();
        if (exteriorRing) {
            [polygon addRingToPolygon];
            for (int i = 0; i < exteriorRing->getNumPoints(); ++i) {
                Coordinate c = exteriorRing->getCoordinateN(i);
                [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
            }
        }
        
        for (int j = 0; j < geosPolygon->getNumInteriorRing(); ++j) {
            const LineString *interiorRing = geosPolygon->getInteriorRingN(j);
            [polygon addRingToPolygon];
            for (int k = 0; k < interiorRing->getNumPoints(); ++k) {
                Coordinate c = interiorRing->getCoordinateN(k);
                [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
            }
        }
    }
    return polygon;
}

+ (AGSPolygon *)agsPolygonFromGeosPolygonRecord:(IPXFeatureRecord *)record
{
    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] init];
    const LineString *exteriorRing = record->getPolygonIfSatisfied()->getExteriorRing();

    if (exteriorRing) {
        [polygon addRingToPolygon];
        for (int i = 0; i < exteriorRing->getNumPoints(); ++i) {
            Coordinate c = exteriorRing->getCoordinateN(i);
            [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
        }
    }
    
    for (int j = 0; j < record->getPolygonIfSatisfied()->getNumInteriorRing(); ++j) {
        const LineString *interiorRing = record->getPolygonIfSatisfied()->getInteriorRingN(j);
        [polygon addRingToPolygon];
        for (int k = 0; k < interiorRing->getNumPoints(); ++k) {
            Coordinate c = interiorRing->getCoordinateN(k);
            [polygon addPointToRing:[AGSPoint pointWithX:c.x y:c.y spatialReference:nil]];
        }
    }
    return polygon;
}

+ (AGSPoint *)agsPointFromGeosPointRecord:(IPXFeatureRecord *)record
{
    return [AGSPoint pointWithX:record->getPointIfSatisfied()->getX() y:record->getPointIfSatisfied()->getY() spatialReference:[TYMapEnvironment defaultSpatialReference]];
}

@end
