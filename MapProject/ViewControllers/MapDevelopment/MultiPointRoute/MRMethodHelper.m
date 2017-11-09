//
//  MethodHelper.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/7.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRMethodHelper.h"

@implementation MRMethodHelper

+ (void)map:(TYMapView *)mapView zoomToAllExtent:(NSArray *)allMapInfos
{
    [mapView disableAutoCenter];
    
    int maxFloor = 1;
    int minFloor = 1;
    TYMapInfo *firstInfo = [allMapInfos objectAtIndex:0];
    double xmax = firstInfo.mapExtent.xmax;
    double xmin = firstInfo.mapExtent.xmin;
    double ymax = firstInfo.mapExtent.ymax;
    double ymin = firstInfo.mapExtent.ymin;
    for (TYMapInfo *info in allMapInfos) {
        if (info.floorNumber > maxFloor) {
            maxFloor = info.floorNumber;
            xmax = info.mapExtent.xmax + (maxFloor - 1) * mapView.building.offset.x;
        }
        
        if (info.floorNumber < minFloor) {
            minFloor = info.floorNumber;
            xmin = info.mapExtent.xmin + (minFloor - 1) * mapView.building.offset.x;
        }
    }
    
    AGSEnvelope *routeEnvelop = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:[TYMapEnvironment defaultSpatialReference]];
    NSLog(@"%@", routeEnvelop);
    [mapView zoomToEnvelope:routeEnvelop animated:YES];
}

+ (void)routeNetwork:(RouteNetworkDataset *)routeNetwork showNodesAndLinksOnLayer:(LayerGroup *)layergroup
{
    NSArray *linkArray = routeNetwork.linkArray;
    NSArray *virtualLinkArray = routeNetwork.virtualLinkArray;
    NSArray *nodeArray = routeNetwork.nodeArray;
    NSArray *virtualNodeArray = routeNetwork.virtualNodeArray;
    
    AGSSimpleLineSymbol *errorLinkSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:3];
    
    for (TYLink *link in linkArray) {
        if (link.currentNodeID == 0 || link.nextNodeID == 0) {
            [layergroup.linkLayer addGraphic:[AGSGraphic graphicWithGeometry:link.line symbol:errorLinkSymbol attributes:nil]];
        } else {
            [layergroup.linkLayer addGraphic:[AGSGraphic graphicWithGeometry:link.line symbol:nil attributes:nil]];
        }
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

@end
