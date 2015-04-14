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


//#define ROUTE_TASK_URL  @"http://192.168.16.24:6080/arcgis/rest/services/0021/00210001_NA/NAServer/Route"


//#define ROUTE_TASK_URL  @"http://192.168.16.122:6080/arcgis/rest/services/002100001/NAServer/Route"
//#define ROUTE_TASK_URL  @"http://192.168.16.122:6080/arcgis/rest/services/002100002/NAServer/Route"


#define ROUTE_TASK_URL  @"http://121.40.16.26:6080/arcgis/rest/services/002100001/NAServer/Route"
//#define ROUTE_TASK_URL  @"http://121.40.16.26:6080/arcgis/rest/services/002100002/NAServer/Route"
//#define ROUTE_TASK_URL  @"http://121.40.16.26:6080/arcgis/rest/services/11/NAServer/Route"


//#define ROUTE_TASK_URL  @"http://192.168.0.109:6080/arcgis/rest/services/Office/office_NA_service/NAServer/Route"

@interface MapRouteVC() <NPRouteManagerDelegate>
{
    NPRouteManager *routeManager;
    
    NPPoint *currentPoint;
    NPLocalPoint *startLocalPoint;
    NPLocalPoint *endLocalPoint;
    
    NPRouteLayer *routeLayer;
    
    BOOL isRouting;
    NPRouteResult *routeResult;
    
    NPGraphicsLayer *hintLayer;
    NPGraphicsLayer *startLayer;
    NPGraphicsLayer *endLayer;
    
    NPPictureMarkerSymbol *startSymbol;
    NPPictureMarkerSymbol *endSymbol;
    NPPictureMarkerSymbol *switchSymbol;
    
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
    
    startLayer = [NPGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:startLayer];
    
    endLayer = [NPGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:endLayer];
    
    hintLayer = [NPGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    NPCredential *credential = [NPMapEnvironment defaultCredential];
    NSURL *routeTaskUrl = [NSURL URLWithString:ROUTE_TASK_URL];
    routeManager = [NPRouteManager routeManagerWithURL:routeTaskUrl credential:credential MapInfos:self.allMapInfos];
    routeManager.delegate = self;
}

- (void)initSymbols
{
    startSymbol = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [NPPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
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
            [routeLayer addGraphic:[NPGraphic graphicWithGeometry:line symbol:nil attributes:nil]];
            
            if ([routeResult isFirstFloor:floor] && [routeResult isLastFloor:floor]) {
                NSLog(@"Same Floor");
                return;
            }
            
            if ([routeResult isFirstFloor:floor] && ![routeResult isLastFloor:floor]) {
                NPPoint *p = [routeResult getLastPointOnFloor:floor];
                if (p) {
                    [routeLayer addGraphic:[NPGraphic graphicWithGeometry:p symbol:switchSymbol attributes:nil]];
                }
                return;
            }
            
            if (![routeResult isFirstFloor:floor] && [routeResult isLastFloor:floor]) {
                NPPoint *p = [routeResult getFirstPointOnFloor:floor];
                if (p) {
                    [routeLayer addGraphic:[NPGraphic graphicWithGeometry:p symbol:switchSymbol attributes:nil]];
                }
                return;
            }
            
            if (![routeResult isFirstFloor:floor] && ![routeResult isLastFloor:floor]) {
                NPPoint *fp = [routeResult getFirstPointOnFloor:floor];
                NPPoint *lp = [routeResult getLastPointOnFloor:floor];
                if (fp) {
                    [routeLayer addGraphic:[NPGraphic graphicWithGeometry:fp symbol:switchSymbol attributes:nil]];
                }
                
                if (lp) {
                    [routeLayer addGraphic:[NPGraphic graphicWithGeometry:lp symbol:switchSymbol attributes:nil]];
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
        [startLayer addGraphic:[NPGraphic graphicWithGeometry:[AGSPoint pointWithX:startLocalPoint.x y:startLocalPoint.y spatialReference:self.mapView.spatialReference] symbol:startSymbol attributes:nil]];
    }
    
    if (endLocalPoint && endLocalPoint.floor == mapInfo.floorNumber) {
        [endLayer addGraphic:[NPGraphic graphicWithGeometry:[AGSPoint pointWithX:endLocalPoint.x y:endLocalPoint.y spatialReference:self.mapView.spatialReference] symbol:startSymbol attributes:nil]];
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


- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(NPPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);
    
    currentPoint = mappoint;
    
    NPSimpleMarkerSymbol *sms = [NPSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
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

