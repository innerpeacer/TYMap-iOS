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
}


@end

@implementation MapVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
//    NSArray *allParkingSpaces = [mapView getParkingSpacesOnCurrentFloor];
//    
//    AGSSimpleFillSymbol *emptySymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor greenColor] outlineColor:[UIColor whiteColor]];
//    AGSSimpleFillSymbol *ocuupiedSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor redColor] outlineColor:[UIColor whiteColor]];
//    for (TYPoi *poi in allParkingSpaces) {
//        int status = arc4random()%2;
//        NSLog(@"%d", status);
//        if (status == 0) {
//            [mapView.parkingLayer addGraphic:[AGSGraphic graphicWithGeometry:poi.geometry symbol:emptySymbol attributes:nil]];
//        } else {
//            [mapView.parkingLayer addGraphic:[AGSGraphic graphicWithGeometry:poi.geometry symbol:ocuupiedSymbol attributes:nil]];
//        }
//    }

}

int count = 0;
int tIndex = 0;

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    testLocation = mappoint;
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
