//
//  MapVC.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapVC.h"
#import "IPAreaAnalysis.h"
#import "TYMapEnviroment.h"
#import "IPBrand.h"
#import "TYUserDefaults.h"
#import "IPPathCalibration.h"

#define PIC_INITIAL 0
#define PIC_LAST 7
@interface MapVC()
{
    IPAreaAnalysis *areaAnalysis;
    
    AGSGraphicsLayer *testLayer;
    NSTimer *testTimer;
    AGSPoint *testLocation;
    AGSSimpleFillSymbol *testSimpleFillSymbol;
    AGSSimpleLineSymbol *testSimpleLineSymbol;
    int currentRadius;
    int picIndex;
    int count;
    int tIndex;
    
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
    
//    [self.mapView setLabelOverlapDetectingEnabled:NO];
    [self.mapView setScaleLevels:@{@(1): @(800)}];

    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    [self.mapView showOccupiedParkingSpaces:occupiedParkingSpaces AvailableParkingSpaces:availableParkingSpaces];
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    
//    NSLog(@"Resolution: %f", self.mapView.resolution);
    NSLog(@"MapScale: %f", self.mapView.mapScale);
    
    NSLog(@"Current Level: %d", [self.mapView getCurrentLevel]);
    
    [hintLayer removeAllGraphics];
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    sms.size = CGSizeMake(5, 5);
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
    
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
