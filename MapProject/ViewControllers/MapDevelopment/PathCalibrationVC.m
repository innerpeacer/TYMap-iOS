//
//  PathCalibrationVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/20.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "PathCalibrationVC.h"
#import "IPAreaAnalysis.h"
#import "TYMapEnviroment.h"
#import "IPBrand.h"
#import "TYUserDefaults.h"
#import "IPPathCalibration.h"


#define PIC_INITIAL 0
#define PIC_LAST 7
@interface PathCalibrationVC()
{
    IPAreaAnalysis *areaAnalysis;
    
    AGSGraphicsLayer *testLayer;
    NSTimer *testTimer;
    AGSPoint *testLocation;
    int count;
    int tIndex;
    AGSSimpleFillSymbol *testSimpleFillSymbol;
    AGSSimpleLineSymbol *testSimpleLineSymbol;
    int currentRadius;
    int picIndex;

    IPPathCalibration *pathCalibration;
    
    AGSGraphicsLayer *pathLayer;
    AGSGraphicsLayer *hintLayer;
}

@end

@implementation PathCalibrationVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    if (pathLayer == nil) {
        pathLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:pathLayer];
    }
    
    pathCalibration = [[IPPathCalibration alloc] initWithMapInfo:mapInfo];
    
    [pathLayer removeAllGraphics];
    AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithRed:1 green:1 blue:0.0 alpha:1] outlineColor:[UIColor colorWithRed:1 green:1 blue:0.0 alpha:1]];
    [pathLayer addGraphic:[AGSGraphic graphicWithGeometry:[pathCalibration getUnionPolygon] symbol:sfs attributes:nil]];
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor]];
    [pathLayer addGraphic:[AGSGraphic graphicWithGeometry:[pathCalibration getUnionPath] symbol:sls attributes:nil]];
}


- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    
    [hintLayer removeAllGraphics];
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    sms.size = CGSizeMake(5, 5);
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
    
    
    testLocation = [pathCalibration calibrationPoint:mappoint];
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
