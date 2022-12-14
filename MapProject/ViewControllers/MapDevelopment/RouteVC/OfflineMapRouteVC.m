//
//  OfflineMapRouteVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/10.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "OfflineMapRouteVC.h"

#import "OfflineRouteManager.h"

#import "IPRouteLayer.h"
#import "TYMapEnviroment.h"
#import "IPRoutePointConverter.h"
#import "TYDirectionalHint.h"

#import "TYRouteResult.h"
#import "TYUserDefaults.h"

#import <objc/message.h>

@interface OfflineMapRouteVC() <OfflineRouteManagerDelegate>
{
    // 路径管理器
    OfflineRouteManager *offlineRouteManager;
    
    AGSPoint *currentPoint;
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
    
    BOOL useClickForChoosingPoint;
    BOOL useClickForSnapRoute;
}

- (IBAction)clickToChoosePoint:(id)sender;
- (IBAction)clickToSnapRoute:(id)sender;
- (IBAction)requtestRoute:(id)sender;
- (IBAction)reset:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *routeHintLabel;

@end

@implementation OfflineMapRouteVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    SEL method = NSSelectorFromString(@"disableAutoCenter");
    if ([self.mapView respondsToSelector:method]) {
        objc_msgSend(self.mapView, method);
    }
//    [self zoomToAllExtent];
    
    [self initSymbols];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    // 初始化路径管理器，并设置代理
    offlineRouteManager = [OfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    offlineRouteManager.delegate = self;
    
    useClickForSnapRoute = NO;
    useClickForChoosingPoint = YES;
    
}

- (void)initSymbols
{
    startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    
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
    
    [hintLayer removeAllGraphics];
    [testLayer removeAllGraphics];
    
    routeResult = rs;
    
    NSLog(@"route part: %d", (int)routeResult.allRoutePartArray.count);
//    TYRoutePart *rp = [routeResult.allRoutePartArray objectAtIndex:0];
//    NSLog(@"point: %d", (int)rp.route.numPoints);
    
    [self.mapView setRouteResult:rs];
    
    [self.mapView setRouteStart:startLocalPoint];
    [self.mapView setRouteEnd:endLocalPoint];
    [self.mapView showRouteResultOnCurrentFloor];
    
    NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.currentMapInfo.floorNumber];
    if (routePartArray && routePartArray.count > 0) {
        currentRoutePart = [routePartArray objectAtIndex:0];
    }
    
    if (currentRoutePart) {
//        [self.mapView zoomToGeometry:currentRoutePart.route withPadding:20.0f animated:YES];
//        routeGuides = [routeResult getRouteDirectionalHint:currentRoutePart];
    }
    
//    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor magentaColor] width:3] attributes:nil]];
}



- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    self.routeHintLabel.text = @"";
    
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
    //    NSLog(@"Map Scale: %f", self.mapView.mapScale);
    currentPoint = mappoint;
    
    TYLocalPoint *localPoint = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    sms.size = CGSizeMake(5, 5);
    
    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
 
    if (useClickForChoosingPoint) {
        startLocalPoint = endLocalPoint;
        endLocalPoint = localPoint;
        [self requtestRoute:nil];
    }
    
    if (useClickForSnapRoute) {
//        [self.mapView showRemainingRouteResultOnCurrentFloor:localPoint];
        [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:localPoint];
    }
}

- (IBAction)clickToChoosePoint:(id)sender
{
    useClickForChoosingPoint = YES;
    useClickForSnapRoute = NO;
}

- (IBAction)clickToSnapRoute:(id)sender
{
    useClickForChoosingPoint = NO;
    useClickForSnapRoute = YES;
}

- (IBAction)requtestRoute:(id)sender {
    
    if (startLocalPoint == nil || endLocalPoint == nil) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要两个点请求路径！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
        return;
    }
    
    routeResult = nil;
    isRouting = YES;
    
    [offlineRouteManager requestRouteWithStart:startLocalPoint End:endLocalPoint];
}

- (IBAction)reset:(id)sender {
    [hintLayer removeAllGraphics];
    
    [self.mapView resetRouteLayer];
    
    startLocalPoint = nil;
    endLocalPoint = nil;
    currentPoint = nil;
    
    isRouting = NO;
    routeResult = nil;
}

- (void)zoomToAllExtent
{
    int maxFloor = 1;
    int minFloor = 1;
    TYMapInfo *firstInfo = [self.allMapInfos objectAtIndex:0];
    double xmax = firstInfo.mapExtent.xmax;
    double xmin = firstInfo.mapExtent.xmin;
    double ymax = firstInfo.mapExtent.ymax;
    double ymin = firstInfo.mapExtent.ymin;
    for (TYMapInfo *info in self.allMapInfos) {
        if (info.floorNumber > maxFloor) {
            maxFloor = info.floorNumber;
            xmax = info.mapExtent.xmax + (maxFloor - 1) * self.currentBuilding.offset.x;
        }
        
        if (info.floorNumber < minFloor) {
            minFloor = info.floorNumber;
            xmin = info.mapExtent.xmin + (minFloor - 1) * self.currentBuilding.offset.x;
        }
    }
    
    AGSEnvelope *routeEnvelop = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:[TYMapEnvironment defaultSpatialReference]];
    NSLog(@"%@", routeEnvelop);
    [self.mapView zoomToEnvelope:routeEnvelop animated:YES];
}


@end
