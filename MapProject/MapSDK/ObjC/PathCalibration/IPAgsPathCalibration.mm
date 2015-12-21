//
//  IPAgsPathCalibration.m
//  MapProject
//
//  Created by innerpeacer on 15/11/19.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPAgsPathCalibration.h"
#import "TYMapEnviroment.h"
#import "IPXPathDBAdapter.hpp"
#import "IPGeos2AgsConverter.h"

#define PATH_CALIBRATION_SOURCE_PATH @"%@_Path"
#define DEFAULT_BUFFER_WIDTH 2.0

using namespace Innerpeacer::MapSDK;

@interface IPAgsPathCalibration()
{
    NSMutableArray *featureArray;
    
    BOOL pathDBExist;
    double width;
    
    AGSGeometry *unionPathLine;
    AGSGeometry *unionPathPolygon;
}

@end

@implementation IPAgsPathCalibration

- (id)initWithMapInfo:(TYMapInfo *)mapInfo
{
    self = [super init];
    if (self) {
        width = DEFAULT_BUFFER_WIDTH;
        
        NSString *buildingDir = [[[TYMapEnvironment getRootDirectoryForMapFiles] stringByAppendingPathComponent:mapInfo.cityID] stringByAppendingPathComponent:mapInfo.buildingID];
        NSString *pathDBName = [NSString stringWithFormat:@"%@_Path.db", mapInfo.mapID];
        NSString *dbPath = [buildingDir stringByAppendingPathComponent:pathDBName];
        
        pathDBExist = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
        if (pathDBExist) {
            IPXPathDBAdapter *db = new IPXPathDBAdapter([dbPath UTF8String]);
            db->open();
            db->readPathData();
            std::vector<geos::geom::LineString *> paths = db->getAllPaths();
            db->close();
            
            featureArray = [[NSMutableArray alloc] init];
            unionPathLine = [[AGSPolyline alloc] init];
            unionPathPolygon = [[AGSPolygon alloc] init];
            
            std::vector<geos::geom::LineString *>::iterator iter;
            for (iter = paths.begin(); iter != paths.end(); ++iter) {
                AGSGeometry *geomtery = [IPGeos2AgsConverter agsGeometryFromGeosGeometry:(*iter)];
                [featureArray addObject:geomtery];
            }
            
            if (featureArray.count > 0) {
                unionPathLine = [[AGSGeometryEngine defaultGeometryEngine] unionGeometries:featureArray];
                unionPathPolygon = [[AGSGeometryEngine defaultGeometryEngine] bufferGeometry:unionPathLine byDistance:width];
            } else {
                pathDBExist = false;
            }
            
        }
    }
    return self;
}

- (void)setBufferWidth:(double)w
{
    width = w;
    
    if (pathDBExist) {
        unionPathPolygon = [[AGSGeometryEngine defaultGeometryEngine] bufferGeometry:unionPathLine byDistance:width];
    }
}

- (AGSPoint *)calibrationPoint:(AGSPoint *)point
{
    if (!pathDBExist) {
        return point;
    }
    
    AGSPoint *result = point;
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    if ([engine geometry:unionPathPolygon containsGeometry:point]) {
        AGSProximityResult *proxmityResult = [engine nearestCoordinateInGeometry:unionPathLine toPoint:point];
        result = proxmityResult.point;
    }
    return result;
}

- (AGSPolyline *)getUnionPath
{
    return (AGSPolyline *)unionPathLine;
}

- (AGSPolygon *)getUnionPolygon
{
    return (AGSPolygon *)unionPathPolygon;
}

@end
