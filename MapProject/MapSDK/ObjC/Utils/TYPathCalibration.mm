//
//  TYPathCalibration.m
//  MapProject
//
//  Created by innerpeacer on 15/11/19.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYPathCalibration.h"
#import "TYMapEnviroment.h"
#import "TYGeos2AgsConverter.h"
#import "IPXPathCalibration.hpp"

#define PATH_CALIBRATION_SOURCE_PATH @"%@_Path"

using namespace Innerpeacer::MapSDK;

@interface TYPathCalibration()
{
    BOOL pathDBExist;
    double width;
    
    IPXPathCalibration *pathCalibration;
    
    AGSGeometry *unionPathLine;
    AGSGeometry *unionPathPolygon;
}

@end

@implementation TYPathCalibration

- (id)initWithMapInfo:(TYMapInfo *)mapInfo
{
    self = [super init];
    if (self) {
        NSString *buildingDir = [[[TYMapEnvironment getRootDirectoryForMapFiles] stringByAppendingPathComponent:mapInfo.cityID] stringByAppendingPathComponent:mapInfo.buildingID];
        NSString *pathDBName = [NSString stringWithFormat:@"%@_Path.db", mapInfo.mapID];
        NSString *dbPath = [buildingDir stringByAppendingPathComponent:pathDBName];
        
        pathDBExist = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
        
        if (pathDBExist) {
            pathCalibration = new IPXPathCalibration([dbPath UTF8String]);
            unionPathLine = [[AGSPolyline alloc] init];
            unionPathPolygon = [[AGSPolygon alloc] init];
            
            int pathCount = pathCalibration->getPathCount();
            if (pathCount > 0) {
                unionPathLine = [TYGeos2AgsConverter agsGeometryFromGeosGeometry:pathCalibration->getUnionPaths()];
                unionPathPolygon = [TYGeos2AgsConverter agsGeometryFromGeosGeometry:pathCalibration->getUnionPathBuffer()];
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
        unionPathPolygon = [TYGeos2AgsConverter agsGeometryFromGeosGeometry:pathCalibration->getUnionPathBuffer()];
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
