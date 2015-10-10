//
//  CppOfflineMapRouteVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "CppOfflineMapRouteVC.h"

#import "OfflineRouteManager.h"

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

@interface CppOfflineMapRouteVC()<OfflineRouteManagerDelegate>
{
    // 路径管理器
    OfflineRouteManager *offlineRouteManager;
    
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
    
    offlineRouteManager = [OfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    offlineRouteManager.delegate = self;
    
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

- (void)routeManager:(OfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"routeManager:routeManager didFailSolveRouteWithError:");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)routeManager:(OfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs OriginalLine:(AGSPolyline *)line
{
    NSLog(@"routeManager: didSolveRouteWithResult:");
    
//    [hintLayer removeAllGraphics];
//    [testLayer removeAllGraphics];
//    
//    routeResult = rs;
//    
//    [self.mapView setRouteResult:rs];
//    [self.mapView setRouteStart:startLocalPoint];
//    [self.mapView setRouteEnd:endLocalPoint];
//    [self.mapView showRouteResultOnCurrentFloor];
//    
//    NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.currentMapInfo.floorNumber];
//    if (routePartArray && routePartArray.count > 0) {
//        currentRoutePart = [routePartArray objectAtIndex:0];
//    }
//    
//    if (currentRoutePart) {
//        routeGuides = [routeResult getRouteDirectionalHint:currentRoutePart];
//    }
//    
//    //    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor magentaColor] width:3] attributes:nil]];
}


//- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
//{
//    if (isRouting) {
//        [self.mapView showRouteResultOnCurrentFloor];
//    }
//}
//
//- (void)TYMapViewDidZoomed:(TYMapView *)mapView
//{
//    if (isRouting) {
//        [self.mapView showRouteResultOnCurrentFloor];
//    }
//}


- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(TYPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);

    
//    [hintLayer removeAllGraphics];
//    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
//    
//    startLocalPoint = endLocalPoint;
//    endLocalPoint = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];;
//    [self requestRoute];
    
}

- (void)requestRoute
{
    if (startLocalPoint == nil || endLocalPoint == nil) {
        return;
    }
    routeResult = nil;
    isRouting = YES;
    [offlineRouteManager requestRouteWithStart:startLocalPoint End:endLocalPoint];
}

@end
