//
//  CppOfflineMapRouteVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "CppOfflineMapRouteVC.h"

#import "TYOfflineRouteManager.h"

#import "IPRouteLayer.h"
#import "TYMapEnviroment.h"
#import "IPRoutePointConverter.h"
#import "TYDirectionalHint.h"

#import "TYRouteResult.h"
#import "TYUserDefaults.h"

#import "FMDatabase.h"

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
    
    AGSGraphicsLayer *hintLayer;
    AGSGraphicsLayer *testLayer;
    
    // 起点、终点、切换点标识符号
    AGSPictureMarkerSymbol *startSymbol;
    AGSPictureMarkerSymbol *endSymbol;
    AGSPictureMarkerSymbol *switchSymbol;
    AGSSimpleMarkerSymbol *markerSymbol;
    
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
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    
    AGSGraphicsLayer *poiLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:poiLayer];
    
    AGSPictureMarkerSymbol *poiSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@""];
    AGSPoint *poiCoord = [AGSPoint pointWithX:0 y:0 spatialReference:self.mapView.spatialReference];
    [poiLayer addGraphic:[AGSGraphic graphicWithGeometry:poiCoord symbol:poiSymbol attributes:nil]];
    
    
    NSDate *now = [NSDate date];
    cppOfflineRouteManager = [TYOfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    cppOfflineRouteManager.delegate = self;
    NSLog(@"加载用时：%f", [[NSDate date] timeIntervalSinceDate:now]);
    
    [self test];
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
    
//    // 当前路径结果的所有路段。我们现在只有一层，一般都只有一个路段
//    NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.currentMapInfo.floorNumber];
//    if (routePartArray && routePartArray.count > 0) {
//        // 获取当前路段，默认为当前层的第一段
//        currentRoutePart = [routePartArray objectAtIndex:0];
//    }
//    
//    if (currentRoutePart) {
////        将地图缩放至当前路段
//        [self.mapView zoomToGeometry:currentRoutePart.route withPadding:100.0f animated:YES];
////        routeGuides = [routeResult getRouteDirectionalHint:currentRoutePart];
//    }
//    
//    TYLocalPoint *location = nil; // 这里使用定位结果
//    
//    // location：定位当前位置。WithThrehold：这里设置一个偏航距离，即偏离路线多少米认为是偏航
//    BOOL isDeviatig = [routeResult isDeviatingFromRoute:location WithThrehold:5.0f];
//    if (isDeviatig) {
//        // 重新请求路径
//    }
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

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);

    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
    
    startLocalPoint = endLocalPoint;
    endLocalPoint = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];;
    [self requestRoute];
}

- (void)test
{
    startLocalPoint = [TYLocalPoint pointWithX:12686097.738200 Y:2560916.977300 Floor:-4];
    endLocalPoint = [TYLocalPoint pointWithX:12686329.959348 Y:2561038.388735 Floor:-4];
    [self requestRoute];
}

static bool first = true;

- (void)requestRoute
{
    if (startLocalPoint == nil || endLocalPoint == nil) {
        return;
    }
    routeResult = nil;
    isRouting = YES;
    
    startDate = [NSDate date];
    
    if (first) {
        startLocalPoint = [TYLocalPoint pointWithX:1.352708016280593E7 Y:3654224.4810018204 Floor:2];
        endLocalPoint = [TYLocalPoint pointWithX:1.3527069115480548E7 Y:3654221.920966998 Floor:2];
        first = false;
    }

    [self.mapView showRouteStartSymbolOnCurrentFloor:startLocalPoint];
    [self.mapView showRouteEndSymbolOnCurrentFloor:endLocalPoint];
    
    [cppOfflineRouteManager requestRouteWithStart:startLocalPoint End:endLocalPoint];
}

- (void)initSymbols
{
    startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    
    markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
}

@end
