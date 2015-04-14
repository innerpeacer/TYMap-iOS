//
//  NPPathModifier.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/1.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPPathCalibration.h"

#define PATH_CALIBRATION_SOURCE_PATH @"%@_Path"
#define DEFAULT_BUFFER_WIDTH 1.0
@interface NPPathCalibration()
{
    NSMutableArray *featureArray;
    
    double width;
    
    AGSGeometry *unionPathLine;
    AGSGeometry *unionPathPolygon;
}

@end


@implementation NPPathCalibration

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

- (void)setBufferWidth:(double)w
{
    width = w;
    unionPathLine = [[AGSGeometryEngine defaultGeometryEngine] unionGeometries:featureArray];
    unionPathPolygon = [[AGSGeometryEngine defaultGeometryEngine] bufferGeometry:unionPathLine byDistance:width];
}

- (AGSPoint *)calibrationPoint:(AGSPoint *)point
{
    AGSPoint *result = point;
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    if ([engine geometry:unionPathPolygon containsGeometry:point]) {
        AGSProximityResult *proxmityResult = [engine nearestCoordinateInGeometry:unionPathLine toPoint:point];
        result = proxmityResult.point;
    }
    return result;
}

@end
