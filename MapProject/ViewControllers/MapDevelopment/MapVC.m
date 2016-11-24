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
#import "TYMapToFengMap.h"

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
    
    self.mapView.highlightPOIOnSelection = YES;
//    [self.mapView setLabelOverlapDetectingEnabled:NO];
    [self.mapView setScaleLevels:@{@(1): @(800)}];

    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
//    [self.mapView setLabelColor:[UIColor redColor]];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    NSLog(@"didFinishLoadingFloor");
    //    NSLog(@"%@", mapInfo);
    //    [self.mapView showOccupiedParkingSpaces:occupiedParkingSpaces AvailableParkingSpaces:availableParkingSpaces];
    
    NSLog(@"%f", self.mapView.resolution);
    NSLog(@"%f", self.mapView.mapScale);
    //    [self.mapView zoomToResolution:0.15 animated:YES];
    //
    //
    
    
    //    double x_start = 0.4; // 0~1
    //    double x_end = 0.8; // 0~1 x_end > x_start
    //
    //    double y_start = 0.1; // 0~1
    //    double y_end = 0.9; // 0~1 y_end > y_start
    //    AGSEnvelope *subEnvelope = [AGSEnvelope envelopeWithXmin:mapInfo.mapExtent.xmin + mapInfo.mapSize.x * x_start ymin:mapInfo.mapExtent.ymin + mapInfo.mapSize.y * y_start  xmax:mapInfo.mapExtent.xmin + mapInfo.mapSize.x * x_end ymax:mapInfo.mapExtent.ymin + mapInfo.mapSize.y * y_end spatialReference:self.mapView.spatialReference];
    //    [self.mapView zoomToEnvelope:subEnvelope animated:YES];

//    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(doSomethingAfterLoading) userInfo:nil repeats:NO];
}

- (void)doSomethingAfterLoading
{
    [self.mapView zoomToResolution:0.15 animated:YES];
    [self.mapView centerAtPoint:[AGSPoint pointWithX:12958080.157497 y:4826082.424206 spatialReference:self.mapView.spatialReference] animated:YES];
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    NSLog(@"Resolution: %f", self.mapView.resolution);
    
//    // 放缩至分辨率。经测试放大到3～4级，使用0.15
//    [self.mapView zoomToResolution:0.15 animated:YES];
//    
    // 居中到某个点
//    [self.mapView centerAtPoint:[AGSPoint pointWithX:mappoint.x y:mappoint.y spatialReference:self.mapView.spatialReference] animated:YES];
//        [self.mapView centerAtPoint:[AGSPoint pointWithX:12958080.157497 y:4826082.424206 spatialReference:self.mapView.spatialReference] animated:YES];

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
    
//    TYPoi *poi = [self.mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
//    NSLog(@"%@", poi);
//
//    static AGSPoint *lastPoint = nil;
//    static CGPoint lastScreenPoint;
//    if (lastPoint == nil) {
//        lastPoint = mappoint;
//        lastScreenPoint = screen;
//        return;
//    }
//    
////    double mapDis = [lastPoint distanceToPoint:mappoint];
////    double screenDis = sqrt(pow(lastScreenPoint.x - screen.x, 2) + pow(lastScreenPoint.y - screen.y, 2));
////    double ratio = mapDis / screenDis;
////    
////    NSLog(@"==================================");
////    NSLog(@"Delta Distance: %f", mapDis);
////    NSLog(@"Screen Distance: %f", screenDis);
////    NSLog(@"Ratio: %f", ratio);
////    NSLog(@"MapScale: %f", self.mapView.mapScale);
////    NSLog(@"MapResoluton: %f", self.mapView.resolution);
////    NSLog(@"Scale To Ratio: %f", self.mapView.mapScale / self.mapView.resolution);
////    
////    double lengthPerPixel = 0.109;
////    double length = lengthPerPixel * screenDis * self.mapView.mapScale / 1000;
////    NSLog(@"Dis VS Dis: %f -- %f", mapDis, length);
////    
////    lastPoint = mappoint;
////    lastScreenPoint = screen;
    
    
//    NSArray *fengMapArray = [TYMapToFengMap TYMapToFengMap:@[@(mappoint.x), @(mappoint.y)]];
//    NSLog(@"TYMap: %f, %f", mappoint.x, mappoint.y);
//    NSLog(@"FengMap: %f, %f", [fengMapArray[0] doubleValue], [fengMapArray[1] doubleValue]);
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

- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array
{
    NSLog(@"%@", array);
}

@end
