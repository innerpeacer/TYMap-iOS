//
//  TYPathCalibration.m
//  MapProject
//
//  Created by innerpeacer on 15/4/1.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYPathCalibration.h"
#import "TYMapEnviroment.h"
#import "IPXPathDBAdapter.hpp"
#import "TYGeos2AgsConverter.h"

#define PATH_CALIBRATION_SOURCE_PATH @"%@_Path"
#define DEFAULT_BUFFER_WIDTH 2.0

using namespace Innerpeacer::MapSDK;

@interface TYPathCalibration()
{
    NSMutableArray *featureArray;
    
    BOOL pathDBExist;
    double width;
    
    AGSGeometry *unionPathLine;
    AGSGeometry *unionPathPolygon;
}

@end


@implementation TYPathCalibration

- (id)initWithFloorID:(NSString *)floorID
{
    self = [super init];
    if (self) {
        width = DEFAULT_BUFFER_WIDTH;
        featureArray = [[NSMutableArray alloc] init];
        unionPathLine = [[AGSPolyline alloc] init];
        unionPathPolygon = [[AGSPolygon alloc] init];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:PATH_CALIBRATION_SOURCE_PATH, floorID] ofType:@"json"];
        if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
            NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:jsonString];
            AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
            for (AGSGraphic *graphic in set.features) {
                [featureArray addObject:graphic.geometry];
            }
            
            unionPathLine = [[AGSGeometryEngine defaultGeometryEngine] unionGeometries:featureArray];
            unionPathPolygon = [[AGSGeometryEngine defaultGeometryEngine] bufferGeometry:unionPathLine byDistance:width];
        }
    }
    return self;
}

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
                AGSGeometry *geomtery = [TYGeos2AgsConverter agsGeometryFromGeosGeometry:(*iter)];
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
        unionPathLine = [[AGSGeometryEngine defaultGeometryEngine] unionGeometries:featureArray];
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
