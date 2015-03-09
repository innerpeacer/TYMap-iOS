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

#define ROUTE_TASK_URL  @"http://192.168.16.14:6080/arcgis/rest/services/0021/00210001_NA/NAServer/Route"
//#define ROUTE_TASK_URL  @"http://192.168.0.109:6080/arcgis/rest/services/Office/office_NA_service/NAServer/Route"

@interface MapRouteVC() <NPRouteManagerDelegate>
{
    NPRouteManager *routeManager;
    
    AGSPoint *currentPoint;
    AGSPoint *startPoint;
    AGSPoint *endPoint;
    
    NPRouteLayer *routeLayer;
    
    AGSGraphicsLayer *hintLayer;
    AGSGraphicsLayer *startLayer;
    AGSGraphicsLayer *endLayer;
    
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
    routeManager = [NPRouteManager routeManagerWithURL:routeTaskUrl credential:credential];
    routeManager.delegate = self;
}

- (void)routeManager:(NPRouteManager *)routeManager didFailRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
    NSLog(@"didFailToRetrieveDefaultRouteTaskParametersWithError:\n%@", error.localizedDescription);
    
}

- (void)routeManager:(NPRouteManager *)routeManager didSolveRouteWithResult:(AGSGraphic *)routeResultGraphic
{
    NSLog(@"routeManager: didSolveRouteWithResult:");
    
    [routeLayer removeAllGraphics];
    [hintLayer removeAllGraphics];
    
    [routeLayer addGraphic:routeResultGraphic];
    
    
    NSMutableArray *graphics = [routeLayer.graphics mutableCopy];
    for (AGSGraphic *g in graphics) {
        if ([g isKindOfClass:[AGSStopGraphic class]]) {
            [routeLayer removeGraphic:g];
        }
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
    startPoint = currentPoint;
    
    [startLayer removeAllGraphics];
    
    AGSPictureMarkerSymbol *pmsStart = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"GreenPushpin"];
    pmsStart.offset = CGPointMake(9, 16);
    [startLayer addGraphic:[AGSGraphic graphicWithGeometry:startPoint symbol:pmsStart attributes:nil]];
    
}

- (IBAction)setEndPoint:(id)sender {
    endPoint = currentPoint;
    
    [endLayer removeAllGraphics];
    
    AGSPictureMarkerSymbol *pmsEnd = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"RedPushpin"];
    pmsEnd.offset = CGPointMake(9, 16);
    [endLayer addGraphic:[AGSGraphic graphicWithGeometry:endPoint symbol:pmsEnd attributes:nil]];
}

- (IBAction)requtestRoute:(id)sender {
    if (startPoint == nil || endPoint == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要两个点请求路径！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [routeManager requestRouteWithStart:startPoint End:endPoint];
}

- (IBAction)reset:(id)sender {
    [hintLayer removeAllGraphics];
    [routeLayer removeAllGraphics];
    [startLayer removeAllGraphics];
    [endLayer removeAllGraphics];
    
    startPoint = nil;
    endPoint = nil;
    currentPoint = nil;
}

@end

