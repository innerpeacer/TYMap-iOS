//
//  TestRouteNetworkVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/5.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TestRouteNetworkVC.h"
#import "RouteNetworkDataset.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"

#import "RouteNetworkDBAdapter.h"

#import "SymbolGroup.h"
#import "LayerGroup.h"

#import <objc/message.h>

@interface TestRouteNetworkVC()
{
    RouteNetworkDataset *routeNetwork;
    SymbolGroup *symbolgroup;
    LayerGroup *layergroup;
    
    AGSGraphicsLayer *testLayer;
    AGSGraphicsLayer *hintLayer;
    
    
    AGSPoint *startPoint;
    AGSPoint *endPoint;
}

@end

@implementation TestRouteNetworkVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    
//    disableAutoCenter
    SEL method = NSSelectorFromString(@"disableAutoCenter");
    if ([self.mapView respondsToSelector:method]) {
        objc_msgSend(self.mapView, method);
    }
    [self zoomToAllExtent];
    self.mapView.backgroundColor = [UIColor lightGrayColor];
    
    RouteNetworkDBAdapter *db = [[RouteNetworkDBAdapter alloc] initWithBuilding:self.currentBuilding];
    [db open];
    routeNetwork = [db readRouteNetworkDataset];
    [db close];
    
    NSLog(@"%@", routeNetwork);
    
    symbolgroup = [[SymbolGroup alloc] init];
    layergroup = [[LayerGroup alloc] init];
    [layergroup addToMap:self.mapView];
    [self showNodesAndLinks];
    
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(testOfflineRoute) userInfo:nil repeats:YES];
}

- (void)showNodesAndLinks
{
    NSArray *linkArray = routeNetwork.linkArray;
    NSArray *virtualLinkArray = routeNetwork.virtualLinkArray;
    NSArray *nodeArray = routeNetwork.nodeArray;
    NSArray *virtualNodeArray = routeNetwork.virtualNodeArray;
    
    for (TYLink *link in linkArray) {
        [layergroup.linkLayer addGraphic:[AGSGraphic graphicWithGeometry:link.line symbol:nil attributes:nil]];
    }
    
    for (TYLink *link in virtualLinkArray) {
        [layergroup.virtualLinkLayer addGraphic:[AGSGraphic graphicWithGeometry:link.line symbol:nil attributes:nil]];
    }
    
    [layergroup.unionLineLayer addGraphic:[AGSGraphic graphicWithGeometry:routeNetwork.unionLine symbol:nil attributes:nil]];
    
    for (TYNode *node in nodeArray) {
        [layergroup.nodeLayer addGraphic:[AGSGraphic graphicWithGeometry:node.pos symbol:nil attributes:nil]];
    }
    
    for (TYNode *node in virtualNodeArray) {
        [layergroup.virtualNodeLayer addGraphic:[AGSGraphic graphicWithGeometry:node.pos symbol:nil attributes:nil]];
    }

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

int TestIndex = 0;
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(TYPoint *)mappoint
{
    NSLog(@"X: %f", mappoint.x);
    BOOL testOffline = YES;
    
    testOffline = NO;
    
    if (testOffline) {
        [self testOfflineRoute];
    } else {
        startPoint = endPoint;
        endPoint = mappoint;
        if (startPoint && endPoint) {
            NSDate *now = [NSDate date];
            
            
            
            [testLayer removeAllGraphics];
            [testLayer addGraphic:[AGSGraphic graphicWithGeometry:startPoint symbol:symbolgroup.testSimpleMarkerSymbol attributes:nil]];
            [testLayer addGraphic:[AGSGraphic graphicWithGeometry:endPoint symbol:symbolgroup.testSimpleMarkerSymbol attributes:nil]];
            
            [testLayer addGraphic:[AGSGraphic graphicWithGeometry:startPoint symbol:symbolgroup.startSymbol attributes:nil]];
            [testLayer addGraphic:[AGSGraphic graphicWithGeometry:endPoint symbol:symbolgroup.endSymbol attributes:nil]];
            
            AGSPolyline *line = [routeNetwork getShorestPathFrom:startPoint To:endPoint];
            [testLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:symbolgroup.testSimpleLineSymbol attributes:nil]];
            for (int i = 0; i < line.numPoints; ++i) {
                AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:[NSString stringWithFormat:@"%d", i] color:[UIColor redColor]];
                ts.offset = CGPointMake(0, 5);
                ts.fontSize = 10;
                
                [testLayer addGraphic:[AGSGraphic graphicWithGeometry:[line pointOnPath:0 atIndex:i] symbol:ts attributes:nil]];
            }
            
            NSDate *endDate = [NSDate date];
            NSLog(@"导航用时：%f", [endDate timeIntervalSinceDate:now]);
        }

    }
}

- (void)testOfflineRoute
{
    if (++TestIndex >= routeNetwork.nodeArray.count) {
        TestIndex = 0;
    }
    
    int randomStart = (int)arc4random()%routeNetwork.nodeArray.count;
    int randomEnd = (int)arc4random()%routeNetwork.nodeArray.count;
    TYNode *start = routeNetwork.nodeArray[randomStart];
    TYNode *end = routeNetwork.nodeArray[randomEnd];
    
    NSDate *now = [NSDate date];
    
    startPoint = [AGSPoint pointWithX:start.pos.x + arc4random() % 5 y:start.pos.y + arc4random()%5 spatialReference:start.pos.spatialReference];
    endPoint = [AGSPoint pointWithX:end.pos.x + arc4random() % 5 y:end.pos.y + arc4random() % 5 spatialReference:end.pos.spatialReference];
    AGSPolyline *line = [routeNetwork getShorestPathFrom:startPoint To:endPoint];
    
    NSDate *endDate = [NSDate date];
    NSLog(@"导航用时：%f", [endDate timeIntervalSinceDate:now]);
    
    [testLayer removeAllGraphics];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:startPoint symbol:symbolgroup.testSimpleMarkerSymbol attributes:nil]];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:endPoint symbol:symbolgroup.testSimpleMarkerSymbol attributes:nil]];
    
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:startPoint symbol:symbolgroup.startSymbol attributes:nil]];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:endPoint symbol:symbolgroup.endSymbol attributes:nil]];
    
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:symbolgroup.testSimpleLineSymbol attributes:nil]];
    
}


@end
