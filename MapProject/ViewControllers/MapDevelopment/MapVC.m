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

#import "TYFanRange.h"

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
    
    AGSSimpleMarkerSymbol *sms;
    int currentRadius;
    int picIndex;
    int count;
    int tIndex;
    
    AGSGraphicsLayer *hintLayer;
    
    NSArray *targetParkingSpaces;
    NSMutableArray *occupiedParkingSpaces;
    NSMutableArray *availableParkingSpaces;
    
    TYFanRange *fanRange;
    
    
    TYLocalPoint *startPoint;
    TYLocalPoint *endPoint;
    AGSGraphic *smoothGraphic;
}


@end

@implementation MapVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    self.mapView.highlightPOIOnSelection = YES;
//    [self.mapView setLabelOverlapDetectingEnabled:NO];
    [self.mapView setScaleLevels:@{@(1): @(800)}];

    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
//    [self.mapView setLabelColor:[UIColor redColor]];
    
    sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms.size = CGSizeMake(5, 5);
    
    fanRange = [[TYFanRange alloc] init];
    [fanRange updateHeading:0.0];
    
}

NSTimer *testTimer;

- (void)testSmooth
{
    [hintLayer removeAllGraphics];
    
    startPoint = [TYLocalPoint pointWithX:13527084.716413 Y:3654220.881112];
    endPoint = [TYLocalPoint pointWithX:13527109.687159 Y:3654211.517083];
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"l7"];
    smoothGraphic = [AGSGraphic graphicWithGeometry:nil symbol:pms attributes:nil];
    
    testTimer = [NSTimer scheduledTimerWithTimeInterval:0.5/steps target:self selector:@selector(smooth) userInfo:nil repeats:YES];
}

int sIndex = 0;
int steps = 10;
- (void)smooth
{
//    NSLog(@"smooth");
    sIndex++;
    if (sIndex >= steps) {
        [testTimer invalidate];
        sIndex = 0;
        return;
    }
    
    float scale = [self easeFuntion:sIndex * 1.0/steps];
    NSLog(@"%d: %f", sIndex, scale);
    TYLocalPoint *point = [self interpolation:scale];
    smoothGraphic.geometry = [AGSPoint pointWithX:point.x y:point.y spatialReference:nil];
    
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:smoothGraphic.geometry symbol:sms attributes:nil]];

    [hintLayer removeGraphic:smoothGraphic];
    [hintLayer addGraphic:smoothGraphic];
}

- (double)easeFuntion:(double)t
{
//    return t;
//    return t * t;
//    return t * t * t;
//    return 1 - (1 - t) * (1 - t);
//    return sin(t * 3.1415926 / 2);
//    return (t <= 0.5) ? t * t : 1 - (1 - t) * (1 - t);
    
    if (t < 0.5) {
        return pow(t, 1.5);
    } else if (t == 0.5) {
        return 0.5;
    } else {
        return 1 - pow((1 - t), 1.5);
    }
    
//    return (t <= 0.5) ? pow(t, 1.5) : 1 - pow((1 - t), 1.5);
//    return (t <= 0.5) ? t * t * t : 1 - (1 - t) * (1 - t) * (1 - t);
}

- (TYLocalPoint *)interpolation:(double)scale
{
    double x = startPoint.x * (1 - scale) + endPoint.x * scale;
    double y = startPoint.y * (1 - scale) + endPoint.y * scale;
    return [TYLocalPoint pointWithX:x Y:y];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    NSLog(@"didFinishLoadingFloor");
    //    NSLog(@"%@", mapInfo);
    NSLog(@"%f", self.mapView.resolution);
    NSLog(@"%f", self.mapView.mapScale);
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
    
//    [hintLayer removeAllGraphics];
//    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
//    sms.size = CGSizeMake(5, 5);
//    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
    
//    testLocation = [self.mapView getCalibratedPoint:mappoint];
//    if (testTimer) {
//        [testTimer invalidate];
//    }
//    testTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(showTestLocation) userInfo:nil repeats:YES];
//    picIndex = PIC_INITIAL;
//    [testLayer removeAllGraphics];
    
//    [fanRange updateCenter:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.currentMapInfo.floorNumber]];
    
//    AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor redColor] outlineColor:[UIColor whiteColor]];
//    AGSGeometry *fanGeometery = [fanRange toFanGeometry];
//    NSLog(@"%@", fanGeometery);
//    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:[fanRange toFanGeometry] symbol:sfs attributes:nil]];
    
//    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor lightGrayColor] width:2];
//    sls.style = AGSSimpleLineSymbolStyleDashDotDot;
//    AGSGeometry *arcGeometry = [fanRange toArcGeometry1WithStartAngle:30 endAngle:240];
//    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:arcGeometry symbol:sls attributes:nil]];
//    
//    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:2];
    
//    [self testSmooth];

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
    for (TYPoi *poi in array) {
        NSLog(@"%@", poi);
        NSLog(@"CateogryID: %d", poi.categoryID);
    }
}

@end
