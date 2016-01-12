//
//  TestCppRouteNetworkVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/12.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TestCppRouteNetworkVC.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"

#import "RouteNetworkDBAdapter.h"

#import "SymbolGroup.h"
#import "LayerGroup.h"

#import <objc/message.h>

#import "IPXRouteNetworkDataset.hpp"
#import "IPXRouteNetworkDBAdapter.hpp"

#import "Geos2AgsConverter.h"

#include <geos/operation/union/CascadedUnion.h>
#include <geos/operation/distance/DistanceOp.h>
#include <geos/linearref/LocationIndexOfPoint.h>
#include <geos/linearref/LinearLocation.h>

using namespace Innerpeacer::MapSDK;
using namespace std;

@interface TestCppRouteNetworkVC()
{
    SymbolGroup *symbolgroup;
    LayerGroup *layergroup;
    
    AGSGraphicsLayer *testLayer;
    AGSGraphicsLayer *hintLayer;
    
    
    AGSPoint *startPoint;
    AGSPoint *endPoint;
    
    int TestIndex;
    
    IPXRouteNetworkDataset *networkDataset;
    geos::geom::MultiLineString *unionLine;
    
    GeometryFactory factory;
    
    int m_tempLinkID;
    
    
    AGSSimpleMarkerSymbol *nearestPointSymbol;
    AGSSimpleMarkerSymbol *nearestPointOnLinkSymbol;
    AGSSimpleMarkerSymbol *nearestVertexOnLinkSymbol;

    AGSSimpleLineSymbol *firstPartTempLinkSymbol;
    AGSSimpleLineSymbol *secondPartTempLinkSymbol;

}

@end

@implementation TestCppRouteNetworkVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    m_tempLinkID = 8000;
    
    [self zoomToAllExtent];
    self.mapView.backgroundColor = [UIColor lightGrayColor];
    
    symbolgroup = [[SymbolGroup alloc] init];
    layergroup = [[LayerGroup alloc] init];
    [layergroup addToMap:self.mapView];
    
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    nearestPointSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    nearestPointSymbol.size = CGSizeMake(7, 7);
    nearestPointSymbol.outline.width = 0.2;
    
    nearestPointOnLinkSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
    nearestPointOnLinkSymbol.size = CGSizeMake(5, 5);
    nearestPointOnLinkSymbol.outline.width = 0.2;

    
    nearestVertexOnLinkSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    nearestVertexOnLinkSymbol.size = CGSizeMake(5, 5);
    nearestVertexOnLinkSymbol.outline.width = 0.2;

    firstPartTempLinkSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor magentaColor]];
    secondPartTempLinkSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor cyanColor]];
    
    NSString *dbPath = [self getRouteDBPath:self.currentBuilding];
    IPXRouteNetworkDBAdapter *db = new IPXRouteNetworkDBAdapter([dbPath UTF8String]);
    db->open();
    networkDataset = db->readRouteNetworkDataset();
    db->close();
    delete db;
    
//    unionLine = networkDataset->m_unionLine;
    
    [self showNodesAndLinks];

    
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
//    NSLog(@"didClickAtPoint:%@", mappoint);
    
    [hintLayer removeAllGraphics];
    
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:symbolgroup.testSimpleMarkerSymbol attributes:nil]];
    
    
//    [self showNearestPoint:mappoint];

    [self showTempNodePoint:mappoint];
    
}

- (void)showTempNodePoint:(AGSPoint *)mappoint
{
//    geos::geom::Point *clickedPoint = [self createPoint:mappoint];
//    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(unionLine, clickedPoint);
//    geos::geom::Point *npOnUnionLine = NULL;
//    if (sequences->size() > 0) {
//        Coordinate coord;
//        coord.x = sequences->front().x;
//        coord.y = sequences->front().y;
//        npOnUnionLine = [self createPointX:sequences->front().x Y:sequences->front().y];
//    }
//    delete sequences;
//    
//    [self showPoint:npOnUnionLine OnLayer:hintLayer WithSymbol:nearestPointSymbol];
//    
//    vector<IPXLink *> m_linkArray = networkDataset->m_linkArray;
//    vector<IPXLink *>::iterator linkIter;
//    
//    for (linkIter = m_linkArray.begin(); linkIter != m_linkArray.end(); ++linkIter) {
//        IPXLink *link = (*linkIter);
//        
//        
//        if (link->getLine()->contains(npOnUnionLine)) {
//            NSLog(@"Contain");
//        } else {
//            double distance = link->getLine()->distance(npOnUnionLine);
//            if (distance < 0.001 && distance > 0) {
//                NSLog(@"Contain: %.10f", distance);
//            } else {
//                //            NSLog(@"Not Contain: %.10f", distance);
//                continue;
//            }
//        }
//        
//        
//        CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(link->getLine(), npOnUnionLine);
//        geos::geom::Point *npOnLink = NULL;
//        if (sequences->size() > 0) {
//            Coordinate coord;
//            coord.x = sequences->front().x;
//            coord.y = sequences->front().y;
//            npOnLink = [self createPointX:sequences->front().x Y:sequences->front().y];
//        }
//        delete sequences;
//        
//        Coordinate coord;
//        coord.x = npOnLink->getX();
//        coord.y = npOnLink->getY();
//        
//        geos::linearref::LinearLocation location = geos::linearref::LocationIndexOfPoint::indexOf(link->getLine(), coord);
//        int index = location.getSegmentIndex();
//
//        if (!location.isVertex()) {
//            [self showPoint:npOnLink OnLayer:hintLayer WithSymbol:nearestPointOnLinkSymbol];
//
//        } else {
//            [self showPoint:npOnLink OnLayer:hintLayer WithSymbol:nearestVertexOnLinkSymbol];
//        }
//        
//        CoordinateArraySequence firstPartSequence;
//        CoordinateArraySequence secondPartSequence;
//        
//        secondPartSequence.add(coord);
//        for (int i = 0; i < link->getLine()->getNumPoints(); ++i) {
//            if (i <= index) {
//                firstPartSequence.add(link->getLine()->getCoordinateN(i));
//            } else {
//                secondPartSequence.add(link->getLine()->getCoordinateN(i));
//            }
//        }
//        firstPartSequence.add(coord);
//        
//        firstPartSequence.removeRepeatedPoints();
//        secondPartSequence.removeRepeatedPoints();
//        
//        LineString *firstPartLineString = factory.createLineString(firstPartSequence);
//        LineString *secondPartLineString = factory.createLineString(secondPartSequence);
//        
//        IPXLink *firstPartLink = new IPXLink(m_tempLinkID, false);
//        firstPartLink->currentNodeID = link->currentNodeID;
//        firstPartLink->length = firstPartLineString->getLength();
//        firstPartLink->setLine(firstPartLineString);
//        
//        IPXLink *secondPartLink = new IPXLink(m_tempLinkID, false);
//        secondPartLink->nextNodeID = link->nextNodeID;
//        secondPartLink->length = secondPartLineString->getLength();
//        secondPartLink->setLine(secondPartLineString);
//        
//        m_tempLinkID++;
//        
//        
//        [self showLine:firstPartLineString OnLayer:hintLayer WithSymbol:firstPartTempLinkSymbol];
//        [self showLine:secondPartLineString OnLayer:hintLayer WithSymbol:secondPartTempLinkSymbol];
//        
//    }
}

- (void)showPoint:(geos::geom::Point *)p OnLayer:(AGSGraphicsLayer *)layer WithSymbol:(AGSSimpleMarkerSymbol *)sms
{
    [layer addGraphic:[AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:p->getX() y:p->getY() spatialReference:nil] symbol:sms attributes:nil]];

}

- (void)showLine:(geos::geom::LineString *)line OnLayer:(AGSGraphicsLayer *)layer WithSymbol:(AGSSimpleLineSymbol *)sls
{
    [layer addGraphic:[AGSGraphic graphicWithGeometry:[Geos2AgsConverter agsPolylineFromGeosLineString:line] symbol:sls attributes:nil]];
}

- (void)showNearestPoint:(AGSPoint *)mappoint
{
    geos::geom::Point *clickedPoint = [self createPoint:mappoint];
    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(unionLine, clickedPoint);
    geos::geom::Point *np = NULL;
    if (sequences->size() > 0) {
        Coordinate coord;
        coord.x = sequences->front().x;
        coord.y = sequences->front().y;
        np = [self createPointX:sequences->front().x Y:sequences->front().y];
    }
    delete sequences;
    

    [self showPoint:np OnLayer:hintLayer WithSymbol:nearestPointSymbol];
}

- (void)showNodesAndLinks
{
//    vector<IPXLink *>::iterator linkIter;
//    
//    for (linkIter = networkDataset->m_linkArray.begin(); linkIter != networkDataset->m_linkArray.end(); ++linkIter) {
//        LineString *line = (*linkIter)->getLine();
//        AGSPolyline *polyline = [Geos2AgsConverter agsPolylineFromGeosLineString:line];
//        [layergroup.linkLayer addGraphic:[AGSGraphic graphicWithGeometry:polyline symbol:nil attributes:nil]];
//    }
////
////    for (linkIter = networkDataset->m_virtualLinkArray.begin(); linkIter != networkDataset->m_virtualLinkArray.end(); ++linkIter) {
////        LineString *line = (*linkIter)->getLine();
////        AGSPolyline *polyline = [Geos2AgsConverter agsPolylineFromGeosLineString:line];
////        [layergroup.virtualLinkLayer addGraphic:[AGSGraphic graphicWithGeometry:polyline symbol:nil attributes:nil]];
////    }
//    
////    AGSPolyline *unionPolyline = [Geos2AgsConverter agsPolylineFromGeosMultiLineString:networkDataset->m_unionLine];
////    [layergroup.unionLineLayer addGraphic:[AGSGraphic graphicWithGeometry:unionPolyline symbol:nil attributes:nil]];
//    
//    vector<IPXNode *>::iterator nodeIter;
//    for (nodeIter = networkDataset->m_nodeArray.begin(); nodeIter != networkDataset->m_nodeArray.end(); ++nodeIter) {
//        geos::geom::Point *pos = (*nodeIter)->getPos();
//        AGSPoint *point = [Geos2AgsConverter agsPointFromGeosPoint:pos];
//        [layergroup.nodeLayer addGraphic:[AGSGraphic graphicWithGeometry:point symbol:nil attributes:nil]];
//    }
//    
//    for (nodeIter = networkDataset->m_virtualNodeArray.begin(); nodeIter != networkDataset->m_virtualNodeArray.end(); ++nodeIter) {
//        geos::geom::Point *pos = (*nodeIter)->getPos();
//        AGSPoint *point = [Geos2AgsConverter agsPointFromGeosPoint:pos];
//        [layergroup.virtualNodeLayer addGraphic:[AGSGraphic graphicWithGeometry:point symbol:nil attributes:nil]];
//    }
    
}

- (void)zoomToAllExtent
{
    SEL method = NSSelectorFromString(@"disableAutoCenter");
    if ([self.mapView respondsToSelector:method]) {
        objc_msgSend(self.mapView, method);
    }
    
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

- (geos::geom::Point *)createPoint:(AGSPoint *)p
{
    Coordinate c;
    c.x = p.x;
    c.y = p.y;
    return factory.createPoint(c);
}

- (geos::geom::Point *)createPointX:(double)x Y:(double)y
{
    Coordinate c;
    c.x = x;
    c.y = y;
    return factory.createPoint(c);
}

- (NSString *)getRouteDBPath:(TYBuilding *)building
{
    NSString *dbName = [NSString stringWithFormat:@"%@.tymap", building.buildingID];
    return [[TYMapEnvironment getBuildingDirectory:building] stringByAppendingPathComponent:dbName];
}

@end
