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

//#define ROUTE_TASK_URL  @"http://192.168.16.24:6080/arcgis/rest/services/0021/00210001_NA/NAServer/Route"


//#define ROUTE_TASK_URL  @"http://192.168.16.122:6080/arcgis/rest/services/002100001/NAServer/Route"
//#define ROUTE_TASK_URL  @"http://192.168.16.122:6080/arcgis/rest/services/002100002/NAServer/Route"


//#define ROUTE_TASK_URL  @"http://121.40.16.26:6080/arcgis/rest/services/002100001/NAServer/Route"
#define ROUTE_TASK_URL  @"http://121.40.16.26:6080/arcgis/rest/services/002100002/NAServer/Route"


//#define ROUTE_TASK_URL  @"http://192.168.0.109:6080/arcgis/rest/services/Office/office_NA_service/NAServer/Route"

@interface MapRouteVC() <NPRouteManagerDelegate>
{
    NPRouteManager *routeManager;
    
    AGSPoint *currentPoint;
    NPLocalPoint *startLocalPoint;
    NPLocalPoint *endLocalPoint;
    
    NPRouteLayer *routeLayer;
    
    BOOL isRouting;
    NPRouteResult *routeResult;
    
    AGSGraphicsLayer *hintLayer;
    AGSGraphicsLayer *startLayer;
    AGSGraphicsLayer *endLayer;
    
    AGSPictureMarkerSymbol *startSymbol;
    AGSPictureMarkerSymbol *endSymbol;
    AGSPictureMarkerSymbol *switchSymbol;
    
}

- (IBAction)setStartPoint:(id)sender;
- (IBAction)setEndPoint:(id)sender;
- (IBAction)requtestRoute:(id)sender;
- (IBAction)reset:(id)sender;

@end
@implementation MapRouteVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSymbols];
    
    routeLayer = [NPRouteLayer routeLayerWithSpatialReference:[NPMapEnvironment defaultSpatialReference]];
    [self.mapView addMapLayer:routeLayer];
    
    startLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:startLayer];
    
    endLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:endLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    AGSCredential *credential = [NPMapEnvironment defaultCredential];
    NSURL *routeTaskUrl = [NSURL URLWithString:ROUTE_TASK_URL];
    routeManager = [NPRouteManager routeManagerWithURL:routeTaskUrl credential:credential MapInfos:self.allMapInfos];
    routeManager.delegate = self;
}

- (void)initSymbols
{
    startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
}

- (void)routeManager:(NPRouteManager *)routeManager didFailRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
    NSLog(@"didFailToRetrieveDefaultRouteTaskParametersWithError:\n%@", error.localizedDescription);
}

- (void)routeManager:(NPRouteManager *)routeManager didSolveRouteWithResult:(NPRouteResult *)rs
{
    NSLog(@"routeManager: didSolveRouteWithResult:");
    
    [hintLayer removeAllGraphics];
    
    routeResult = rs;
    [self showRouteResultOnCurrentFloor];
}

- (void)showRouteResultOnCurrentFloor
{
    [routeLayer removeAllGraphics];
    if (routeResult) {
        int floor = self.mapView.currentMapInfo.floorNumber;
        
        AGSPolyline *line = [routeResult getRouteOnFloor:floor];
        if (line) {
            [routeLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:nil attributes:nil]];
            
            if ([routeResult isFirstFloor:floor] && [routeResult isLastFloor:floor]) {
                NSLog(@"Same Floor");
                return;
            }
            
            if ([routeResult isFirstFloor:floor] && ![routeResult isLastFloor:floor]) {
                AGSPoint *p = [routeResult getLastPointOnFloor:floor];
                if (p) {
                    [routeLayer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:switchSymbol attributes:nil]];
                }
                return;
            }
            
            if (![routeResult isFirstFloor:floor] && [routeResult isLastFloor:floor]) {
                AGSPoint *p = [routeResult getFirstPointOnFloor:floor];
                if (p) {
                    [routeLayer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:switchSymbol attributes:nil]];
                }
                return;
            }
            
            if (![routeResult isFirstFloor:floor] && ![routeResult isLastFloor:floor]) {
                AGSPoint *fp = [routeResult getFirstPointOnFloor:floor];
                AGSPoint *lp = [routeResult getLastPointOnFloor:floor];
                if (fp) {
                    [routeLayer addGraphic:[AGSGraphic graphicWithGeometry:fp symbol:switchSymbol attributes:nil]];
                }
                
                if (lp) {
                    [routeLayer addGraphic:[AGSGraphic graphicWithGeometry:lp symbol:switchSymbol attributes:nil]];
                }
                return;
            }
        }
        
    }
}

- (IBAction)floorChanged:(id)sender
{
    [startLayer removeAllGraphics];
    [endLayer removeAllGraphics];
    [routeLayer removeAllGraphics];
    
    [super floorChanged:sender];
   
}

- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo
{
    if (startLocalPoint && startLocalPoint.floor == mapInfo.floorNumber) {
        [startLayer addGraphic:[AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:startLocalPoint.x y:startLocalPoint.y spatialReference:self.mapView.spatialReference] symbol:startSymbol attributes:nil]];
    }
    
    if (endLocalPoint && endLocalPoint.floor == mapInfo.floorNumber) {
        [endLayer addGraphic:[AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:endLocalPoint.x y:endLocalPoint.y spatialReference:self.mapView.spatialReference] symbol:startSymbol attributes:nil]];
    }
    
    if (isRouting) {
        [self showRouteResultOnCurrentFloor];
    }
    
    
}

- (void)routeManager:(NPRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"routeManager:routeManager didFailSolveRouteWithError:");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);
    
    currentPoint = mappoint;
    
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    sms.size = CGSizeMake(5, 5);
    
    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms                                                attributes:nil]];
}

- (IBAction)setStartPoint:(id)sender {
    startLocalPoint = [NPLocalPoint pointWithX:currentPoint.x Y:currentPoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    [startLayer removeAllGraphics];
    [startLayer addGraphic:[AGSGraphic graphicWithGeometry:currentPoint symbol:startSymbol attributes:nil]];
    
}

- (IBAction)setEndPoint:(id)sender {
    endLocalPoint = [NPLocalPoint pointWithX:currentPoint.x Y:currentPoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    [endLayer removeAllGraphics];
    [endLayer addGraphic:[AGSGraphic graphicWithGeometry:currentPoint symbol:endSymbol attributes:nil]];
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
    [routeLayer removeAllGraphics];
    [startLayer removeAllGraphics];
    [endLayer removeAllGraphics];
    
    startLocalPoint = nil;
    endLocalPoint = nil;
    currentPoint = nil;
    
    isRouting = NO;
    routeResult = nil;
}

@end

