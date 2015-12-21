//
//  IPPathCalibration.m
//  MapProject
//
//  Created by innerpeacer on 15/11/19.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPPathCalibration.h"
#import "TYMapEnviroment.h"
#import "IPGeos2AgsConverter.h"
#import "IPXPathCalibration.hpp"

#define PATH_CALIBRATION_SOURCE_PATH @"%@_Path.db"

using namespace Innerpeacer::MapSDK;

@interface IPPathCalibration()
{
    BOOL pathDBExist;
    double width;
    
    IPXPathCalibration *pathCalibration;
    
    AGSGeometry *unionPathLine;
    AGSGeometry *unionPathPolygon;
}

@end

@implementation IPPathCalibration

- (id)initWithMapInfo:(TYMapInfo *)mapInfo
{
    self = [super init];
    if (self) {
        NSString *buildingDir = [[[TYMapEnvironment getRootDirectoryForMapFiles] stringByAppendingPathComponent:mapInfo.cityID] stringByAppendingPathComponent:mapInfo.buildingID];
        NSString *pathDBName = [NSString stringWithFormat:PATH_CALIBRATION_SOURCE_PATH, mapInfo.mapID];
        NSString *dbPath = [buildingDir stringByAppendingPathComponent:pathDBName];
        
        pathDBExist = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
        
        if (pathDBExist) {
            pathCalibration = new IPXPathCalibration([dbPath UTF8String]);
            unionPathLine = [[AGSPolyline alloc] init];
            unionPathPolygon = [[AGSPolygon alloc] init];
            
            int pathCount = pathCalibration->getPathCount();
            if (pathCount > 0) {
                unionPathLine = [IPGeos2AgsConverter agsGeometryFromGeosGeometry:pathCalibration->getUnionPaths()];
                unionPathPolygon = [IPGeos2AgsConverter agsGeometryFromGeosGeometry:pathCalibration->getUnionPathBuffer()];
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
        pathCalibration->setBufferWidth(width);
        unionPathPolygon = [IPGeos2AgsConverter agsGeometryFromGeosGeometry:pathCalibration->getUnionPathBuffer()];
    }
}

- (AGSPoint *)calibrationPoint:(AGSPoint *)point
{
    if (!pathDBExist) {
        return point;
    }
    
    Coordinate c;
    c.x = point.x;
    c.y = point.y;
    Coordinate result = pathCalibration->calibratePoint(c);
    
    return [AGSPoint pointWithX:result.x y:result.y spatialReference:point.spatialReference];
}

- (AGSPolyline *)getUnionPath
{
    return (AGSPolyline *)unionPathLine;
}

- (AGSPolygon *)getUnionPolygon
{
    return (AGSPolygon *)unionPathPolygon;
}

- (void)dealloc
{
    if (pathCalibration) {
        delete pathCalibration;
    }
}

@end
