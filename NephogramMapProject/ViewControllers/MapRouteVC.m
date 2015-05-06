//
//  MapRouteVC.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapRouteVC.h"

#import "NPRouteManager.h"
#import "NPRouteLayer.h"
#import "NPMapEnviroment.h"
#import "NPRoutePointConverter.h"
#import "NPGraphicsLayer.h"
#import "NPPictureMarkerSymbol.h"
#import "NPCredential.h"
#import "NPGraphic.h"
#import "NPSimpleMarkerSymbol.h"
#import "NPPoint.h"
#import "NPDirectionalString.h"

@interface MapRouteVC() <NPRouteManagerDelegate>
{
    NPRouteManager *routeManager;
    
    NPPoint *currentPoint;
    NPLocalPoint *startLocalPoint;
    NPLocalPoint *endLocalPoint;
    
    BOOL isRouting;
    NPRouteResult *routeResult;
    
    NSArray *routeGuides;
    
    NPGraphicsLayer *hintLayer;
    
    NPPictureMarkerSymbol *startSymbol;
    NPPictureMarkerSymbol *endSymbol;
    NPPictureMarkerSymbol *switchSymbol;

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
    
    hintLayer = [NPGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    routeManager = [NPRouteManager routeManagerWithBuilding:self.currentBuilding credential:[NPMapEnvironment defaultCredential] MapInfos:self.allMapInfos];
    routeManager.delegate = self;
}

- (void)initSymbols
{
    startSymbol = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
}

- (void)routeManagerDidRetrieveDefaultRouteTaskParameters:(NPRouteManager *)routeManager
{
//    NSLog(@"routeManagerDidRetrieveDefaultRouteTaskParameters");
}

- (void)routeManager:(NPRouteManager *)routeManager didFailRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
//    NSLog(@"didFailToRetrieveDefaultRouteTaskParametersWithError:\n%@", error.localizedDescription);
}

- (void)routeManager:(NPRouteManager *)routeManager didSolveRouteWithResult:(NPRouteResult *)rs
{
//    NSLog(@"routeManager: didSolveRouteWithResult:");
    
    [hintLayer removeAllGraphics];
    
    routeResult = rs;
    [self.mapView setRouteResult:rs];
    [self.mapView setRouteStart:startLocalPoint];
    [self.mapView setRouteEnd:endLocalPoint];
    [self.mapView showRouteResultOnCurrentFloor];
    
    routeGuides = [routeResult getRouteDirectionStringOnFloor:self.currentMapInfo];
    for (NPDirectionalString *ds in routeGuides) {
        NSLog(@"%@", [ds getDirectionString]);
    }
}

- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
        
        routeGuides = [routeResult getRouteDirectionStringOnFloor:self.currentMapInfo];
    }
}

- (void)NPMapViewDidZoomed:(NPMapView *)mapView
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

- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(NPPoint *)mappoint
{
//    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);
//    NSLog(@"Map Scale: %f", self.mapView.mapScale);
    currentPoint = mappoint;
    
    NPLocalPoint *localPoint = [NPLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    
    NPSimpleMarkerSymbol *sms = [NPSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    sms.size = CGSizeMake(5, 5);
    
    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
    
    if (routeResult) {
        
        if (routeGuides && routeGuides.count > 0) {
            if (testIndex >= routeGuides.count) {
                testIndex = 0;
            }
            
            AGSPolyline *currentLine = [routeResult getRouteOnFloor:self.mapView.currentMapInfo.floorNumber];
            NPDirectionalString *ds = routeGuides[testIndex++];
            AGSPolyline *subLine = [NPRouteResult getSubPolyline:currentLine WithStart:ds.startPoint End:ds.endPoint];
            
            AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor greenColor] width:2.0];
            [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:subLine symbol:sls attributes:nil]];

            self.routeHintLabel.text = [ds getDirectionString];
            
            AGSPoint *center = [AGSPoint pointWithX:(ds.startPoint.x + ds.endPoint.x)*0.5 y:(ds.startPoint.y + ds.endPoint.y)*0.5 spatialReference:[NPMapEnvironment defaultSpatialReference]];
            [self.mapView centerAtPoint:center animated:YES];
//            [self.mapView zoomToGeometry:subLine withPadding:300 animated:YES];
            
        }
        
//        BOOL isDeviating = [routeResult isDeviatingFromRoute:localPoint WithThrehold:2.0];
//        
//        if (isDeviating) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"已经偏离导航线，重新规划！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            [routeManager requestRouteWithStart:localPoint End:endLocalPoint];
//        } else {
//            [self.mapView showRemainingRouteResultOnCurrentFloor:localPoint];
//        }

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

