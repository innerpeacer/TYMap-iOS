//
//  CppOfflineMapRouteVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "CppOfflineMapRouteVC.h"

#import "TYOfflineRouteManager.h"

#import "TYRouteLayer.h"
#import "TYMapEnviroment.h"
#import "TYRoutePointConverter.h"
#import "TYGraphicsLayer.h"
#import "TYPictureMarkerSymbol.h"
#import "TYCredential.h"
#import "TYGraphic.h"
#import "TYSimpleMarkerSymbol.h"
#import "TYPoint.h"
#import "TYDirectionalHint.h"

#import "TYRouteResult.h"
#import "TYUserDefaults.h"

@interface CppOfflineMapRouteVC()<TYOfflineRouteManagerDelegate>
{
    // 路径管理器
    TYOfflineRouteManager *cppOfflineRouteManager;
    
    TYLocalPoint *startLocalPoint;
    TYLocalPoint *endLocalPoint;
    
    BOOL isRouting;
    
    // 路径规划结果
    TYRouteResult *routeResult;
    
    TYRoutePart *currentRoutePart;
    NSArray *routeGuides;
    
    TYGraphicsLayer *hintLayer;
    AGSGraphicsLayer *testLayer;
    
    
    // 起点、终点、切换点标识符号
    TYPictureMarkerSymbol *startSymbol;
    TYPictureMarkerSymbol *endSymbol;
    TYPictureMarkerSymbol *switchSymbol;
    TYSimpleMarkerSymbol *markerSymbol;
    
    
    NSDate *startDate;
    NSDate *endDate;
}

@end

@implementation CppOfflineMapRouteVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    
    [self initSymbols];
    hintLayer = [TYGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    NSDate *now = [NSDate date];
    cppOfflineRouteManager = [TYOfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    cppOfflineRouteManager.delegate = self;
    NSLog(@"加载用时：%f", [[NSDate date] timeIntervalSinceDate:now]);
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    endDate = [NSDate date];
    NSLog(@"导航用时：%f", [endDate timeIntervalSinceDate:startDate]);
    
    [hintLayer removeAllGraphics];
    [testLayer removeAllGraphics];
    
    routeResult = rs;
    
    [self.mapView setRouteResult:rs];
    [self.mapView setRouteStart:startLocalPoint];
    [self.mapView setRouteEnd:endLocalPoint];
    [self.mapView showRouteResultOnCurrentFloor];
    
    NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.currentMapInfo.floorNumber];
    if (routePartArray && routePartArray.count > 0) {
        currentRoutePart = [routePartArray objectAtIndex:0];
    }
    
    if (currentRoutePart) {
        routeGuides = [routeResult getRouteDirectionalHint:currentRoutePart];
    }

}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}


- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(TYPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);

    
    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
    
    startLocalPoint = endLocalPoint;
    endLocalPoint = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];;
    [self requestRoute];
    
}

- (void)requestRoute
{
    if (startLocalPoint == nil || endLocalPoint == nil) {
        return;
    }
    routeResult = nil;
    isRouting = YES;
    
    startDate = [NSDate date];
    
    startLocalPoint = [TYLocalPoint pointWithX:13402386.8918 Y:4287405.314801339 Floor:1];
    endLocalPoint = [TYLocalPoint pointWithX:13402418.04687074 Y:4287369.954955366 Floor:1];
    
//    startPoint = new TYLocalPoint(13275974.30287264, 2989071.967726886, 3);
//    endPoint = new TYLocalPoint(13275987.1889, 2989087.670699999, 3);
    
    
    [cppOfflineRouteManager requestRouteWithStart:startLocalPoint End:endLocalPoint];
}

- (void)initSymbols
{
    startSymbol = [TYPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [TYPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [TYPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    
    markerSymbol = [TYSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
}

@end
