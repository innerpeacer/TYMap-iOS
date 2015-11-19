//
//  MapVC.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapVC.h"
#import "TYAreaAnalysis.h"
#import "TYMapEnviroment.h"
#import "TYBrand.h"
#import "TYUserDefaults.h"
#import "TYPathCalibration.h"

@interface MapVC()
{
    TYAreaAnalysis *areaAnalysis;
    
    AGSGraphicsLayer *testLayer;
    NSTimer *testTimer;
    AGSPoint *testLocation;
    AGSSimpleFillSymbol *testSimpleFillSymbol;
    AGSSimpleLineSymbol *testSimpleLineSymbol;
    int currentRadius;
    int picIndex;
    
    TYPathCalibration *pathCalibration;
    
    AGSGraphicsLayer *pathLayer;
    AGSGraphicsLayer *hintLayer;
    
    NSArray *targetParkingSpaces;
    NSMutableArray *occupiedParkingSpaces;
    NSMutableArray *availableParkingSpaces;
}


@end

@implementation MapVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    targetParkingSpaces = @[@"00100003B0210266", @"00100003B0210281", @"00100003B0210258", @"00100003B0210262", @"00100003B0210279", @"00100003B0210265", @"00100003B0210263", @"00100003B0210280", @"00100003B0210260", @"00100003B0210275", @"00100003B0210286", @"00100003B0210274", @"00100003B0210273", @"00100003B0210285", @"00100003B0210271", @"00100003B0210268", @"00100003B0210290", @"00100003B0210269"];
    occupiedParkingSpaces = [NSMutableArray array];
    availableParkingSpaces = [NSMutableArray array];
    for (NSString *poiID in targetParkingSpaces) {
        int status = arc4random()%2;
        if (status == 0) {
            [occupiedParkingSpaces addObject:poiID];
        } else {
            [availableParkingSpaces addObject:poiID];
        }
    }

    
    
    [super viewDidLoad];
    
    pathLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:pathLayer];
    
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    

    
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    [self.mapView showOccupiedParkingSpaces:occupiedParkingSpaces AvailableParkingSpaces:availableParkingSpaces];

    pathCalibration = [[TYPathCalibration alloc] initWithMapInfo:mapInfo];
    
    [pathLayer removeAllGraphics];
    AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithRed:1 green:1 blue:0.0 alpha:1] outlineColor:[UIColor colorWithRed:1 green:1 blue:0.0 alpha:1]];
    [pathLayer addGraphic:[AGSGraphic graphicWithGeometry:[pathCalibration getUnionPolygon] symbol:sfs attributes:nil]];
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor]];
    [pathLayer addGraphic:[AGSGraphic graphicWithGeometry:[pathCalibration getUnionPath] symbol:sls attributes:nil]];
}

int count = 0;
int tIndex = 0;
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    
    [hintLayer removeAllGraphics];
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    sms.size = CGSizeMake(5, 5);
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
    
    
//    testLocation = [pathCalibration calibrationPoint:mappoint];
    testLocation = [self.mapView getCalibratedPoint:mappoint];
    if (testTimer) {
        [testTimer invalidate];
    }
    testTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(showTestLocation) userInfo:nil repeats:YES];
    picIndex = PIC_INITIAL;
    [testLayer removeAllGraphics];
    
    TYPoi *poi = [self.mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
    NSLog(@"%@", poi);
    
}

const int PIC_INITIAL = 0;
const int PIC_LAST = 7;
- (void)showTestLocation
{
    [testLayer removeAllGraphics];
    
    if (picIndex > PIC_LAST) {
        picIndex = PIC_INITIAL;
    }
    NSString *imageName = [NSString stringWithFormat:@"l%d", picIndex++];
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:imageName];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:testLocation symbol:pms attributes:nil]];
}

@end
