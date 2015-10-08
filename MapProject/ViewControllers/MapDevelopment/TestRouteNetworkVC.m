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

@interface TestRouteNetworkVC()
{
    RouteNetworkDataset *routeNetwork;
    SymbolGroup *symbolgroup;
    LayerGroup *layergroup;
    
    AGSGraphicsLayer *testLayer;
    AGSGraphicsLayer *hintLayer;
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
    

}

- (void)showNodesAndLinks
{
    NSMutableArray *linkArray = [NSMutableArray array];
    NSMutableArray *virtualLinkArray = [NSMutableArray array];
    NSMutableArray *nodeArray = [NSMutableArray array];
    NSMutableArray *virtualNodeArray = [NSMutableArray array];

    
    for (TYLink *link in routeNetwork.allLinkArray) {
        if (link.isVirtual) {
            [virtualLinkArray addObject:link];
        } else {
            [linkArray addObject:link];
        }
    }
    
    for (TYNode *node in routeNetwork.allNodeArray) {
        if (node.isVirtual) {
            [virtualNodeArray addObject:node];
        } else {
            [nodeArray addObject:node];
        }
    }
    
    for (TYLink *link in linkArray) {
        [layergroup.linkLayer addGraphic:[AGSGraphic graphicWithGeometry:link.line symbol:nil attributes:nil]];
    }
    
    for (TYLink *link in virtualLinkArray) {
        [layergroup.virtualLinkLayer addGraphic:[AGSGraphic graphicWithGeometry:link.line symbol:nil attributes:nil]];
    }
    
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
    [self testOfflineRoute];
}

- (void)testOfflineRoute
{
    if (++TestIndex >= routeNetwork.allNodeArray.count) {
        TestIndex = 0;
    }
    
    
    //    int randomStart = (int)arc4random()%routeManager.routeNetworkDataset.allNodeArray.count;
    //    int randomEnd = (int)arc4random()%routeManager.routeNetworkDataset.allNodeArray.count;
    //    TYNode *start = routeManager.routeNetworkDataset.allNodeArray[randomStart];
    //    TYNode *end = routeManager.routeNetworkDataset.allNodeArray[randomEnd];
    
    int randomStart = (int)arc4random()%routeNetwork.allNodeArray.count;
    int randomEnd = (int)arc4random()%routeNetwork.allNodeArray.count;
    TYNode *start = routeNetwork.allNodeArray[randomStart];
    TYNode *end = routeNetwork.allNodeArray[randomEnd];
    
    //    NSDate *now = [NSDate date];
    //    NSArray *path = [routeManager solvePathFrom:start To:end];
    
    [routeNetwork reset];
    [routeNetwork computePaths:start];
    NSArray *path = [routeNetwork getShorestPathTo:end];
    
    
    //    NSDate *endDate = [NSDate date];
    //    NSLog(@"导航用时：%f", [endDate timeIntervalSinceDate:now]);
    
    [testLayer removeAllGraphics];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:start.pos symbol:symbolgroup.testSimpleMarkerSymbol attributes:nil]];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:end.pos symbol:symbolgroup.testSimpleMarkerSymbol attributes:nil]];
    
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:start.pos symbol:symbolgroup.startSymbol attributes:nil]];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:end.pos symbol:symbolgroup.endSymbol attributes:nil]];
    
    int count = 0;
    NSMutableArray *lineArray = [NSMutableArray array];
    for (TYNode *node in path) {
        if (node && node.previousNode) {
            NSString *key = [NSString stringWithFormat:@"%d%d", node.nodeID, node.previousNode.nodeID];
            TYLink *link = [routeNetwork.allLinkDict objectForKey:key];
            //            [testLayer addGraphic:[AGSGraphic graphicWithGeometry:link.line symbol:symbolgroup.testSimpleLineSymbol attributes:nil]];
            [lineArray addObject:link.line];
            //            NSLog(@"Points: %d", (int)link.line.numPoints);
            count += link.line.numPoints;
        }
    }
    
    AGSPolyline *line = (AGSPolyline *)[[AGSGeometryEngine defaultGeometryEngine] unionGeometries:lineArray];
    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:symbolgroup.testSimpleLineSymbol attributes:nil]];
}


@end
