//
//  MapRouteVC.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapRouteVC.h"

#import "NPRouteManager.h"
#import "TYRouteLayer.h"
#import "NPMapEnviroment.h"
#import "NPRoutePointConverter.h"
#import "TYGraphicsLayer.h"
#import "TYPictureMarkerSymbol.h"
#import "TYCredential.h"
#import "TYGraphic.h"
#import "TYSimpleMarkerSymbol.h"
#import "TYPoint.h"
#import "NPDirectionalHint.h"

#import "NPRouteResult.h"

@interface MapRouteVC() <NPRouteManagerDelegate>
{
    NPRouteManager *routeManager;
    
    TYPoint *currentPoint;
    NPLocalPoint *startLocalPoint;
    NPLocalPoint *endLocalPoint;
    
    BOOL isRouting;
    NPRouteResult *routeResult;
    
    NPRoutePart *currentRoutePart;
    NSArray *routeGuides;
    
    TYGraphicsLayer *hintLayer;
    
    TYPictureMarkerSymbol *startSymbol;
    TYPictureMarkerSymbol *endSymbol;
    TYPictureMarkerSymbol *switchSymbol;

}

- (IBAction)setStartPoint:(id)sender;
- (IBAction)setEndPoint:(id)sender;
- (IBAction)requtestRoute:(id)sender;
- (IBAction)reset:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *routeHintLabel;

@end

@implementation MapRouteVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSymbols];
    
    hintLayer = [TYGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    routeManager = [NPRouteManager routeManagerWithBuilding:self.currentBuilding credential:[TYMapEnvironment defaultCredential] MapInfos:self.allMapInfos];
    routeManager.delegate = self;
    
//    [self.mapView zoomToEnvelope:[AGSEnvelope envelopeWithXmin:1780 ymin:432.187299 xmax:1944.755560 ymax:658.589997 spatialReference:[NPMapEnvironment defaultSpatialReference]] animated:YES];
//    endLocalPoint = [NPLocalPoint pointWithX:1779.204079 Y:581.868337 Floor:self.mapView.currentMapInfo.floorNumber];
//    startLocalPoint = [NPLocalPoint pointWithX:1917 Y:558 Floor:self.mapView.currentMapInfo.floorNumber];
    
//    startLocalPoint = [NPLocalPoint pointWithX:-16368295.127012 Y:406.263263 Floor:self.mapView.currentMapInfo.floorNumber];
//    endLocalPoint = [NPLocalPoint pointWithX:-16368298.841312 Y:417.294456 Floor:self.mapView.currentMapInfo.floorNumber];

}

- (void)initSymbols
{
    startSymbol = [TYPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [TYPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [TYPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
}

- (void)routeManagerDidRetrieveDefaultRouteTaskParameters:(NPRouteManager *)routeManager
{
    NSLog(@"routeManagerDidRetrieveDefaultRouteTaskParameters");
}

- (void)routeManager:(NPRouteManager *)routeManager didFailRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
//    NSLog(@"didFailToRetrieveDefaultRouteTaskParametersWithError:\n%@", error.localizedDescription);
}

- (void)routeManager:(NPRouteManager *)routeManager didSolveRouteWithResult:(NPRouteResult *)rs
{
    NSLog(@"routeManager: didSolveRouteWithResult:");
    
    [hintLayer removeAllGraphics];
    
    routeResult = rs;
    
    NSLog(@"route part: %d", (int)routeResult.allRoutePartArray.count);
    NPRoutePart *rp = [routeResult.allRoutePartArray objectAtIndex:0];
    NSLog(@"point: %d", (int)rp.route.numPoints);
    
    AGSGraphicsLayer *testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    
    for (int i = 0; i < rp.route.numPoints; i++) {
        NSLog(@"P: %@", [rp.route pointOnPath:0 atIndex:i]);
        [testLayer addGraphic:[AGSGraphic graphicWithGeometry:[rp.route pointOnPath:0 atIndex:i] symbol:sms attributes:nil]];
    }
    
    
    
    
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
    
//    for (NPDirectionalHint *ds in routeGuides) {
//        NSLog(@"%@", [ds getDirectionString]);
//    }
}

- (void)NPMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    self.routeHintLabel.text = @"";
    
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}

- (void)NPMapViewDidZoomed:(TYMapView *)mapView
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}

- (void)routeManager:(NPRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"routeManager:routeManager didFailSolveRouteWithError:");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


int testIndex = 0;

- (void)NPMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(TYPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);
//    NSLog(@"Map Scale: %f", self.mapView.mapScale);
    currentPoint = mappoint;
    
    NPLocalPoint *localPoint = [NPLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    
    TYSimpleMarkerSymbol *sms = [TYSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    sms.size = CGSizeMake(5, 5);
    
    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
    
    if (routeResult) {
//        BOOL isDeviating = [routeResult isDeviatingFromRoute:localPoint WithThrehold:10.0];
//        
//        if (isDeviating) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"已经偏离导航线，重新规划！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            [routeManager requestRouteWithStart:localPoint End:endLocalPoint];
//        } else {
//            [self.mapView showRemainingRouteResultOnCurrentFloor:localPoint];
//        }
        
        NPRoutePart *nearestPart = [routeResult getNearestRoutePart:localPoint];
        if (nearestPart != currentRoutePart) {
            currentRoutePart = nearestPart;
            routeGuides = [routeResult getRouteDirectionalHint:currentRoutePart];
        }
        
        if (routeGuides && routeGuides.count > 0) {
            NPDirectionalHint *hint = [routeResult getDirectionHintForLocation:localPoint FromHints:routeGuides];
            [self.mapView showRouteHintForDirectionHint:hint Centered:YES];
            self.routeHintLabel.text = [hint getDirectionString];
        }
    }
}

- (IBAction)setStartPoint:(id)sender {
    startLocalPoint = [NPLocalPoint pointWithX:currentPoint.x Y:currentPoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    [self.mapView showRouteStartSymbolOnCurrentFloor:startLocalPoint];
    
}

- (IBAction)setEndPoint:(id)sender {
    endLocalPoint = [NPLocalPoint pointWithX:currentPoint.x Y:currentPoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    [self.mapView showRouteEndSymbolOnCurrentFloor:endLocalPoint];
}

- (IBAction)requtestRoute:(id)sender {
    
    if (startLocalPoint == nil || endLocalPoint == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要两个点请求路径！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    routeResult = nil;
    isRouting = YES;
    
    [routeManager requestRouteWithStart:startLocalPoint End:endLocalPoint];
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

@end

