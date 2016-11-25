//
//  TraceLayerVC.m
//  MapProject
//
//  Created by innerpeacer on 2016/11/24.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "TraceLayerVC.h"
#import "TYUserDefaults.h"
#import "TYTraceLayerV2.h"
#import "TYSnappingManager.h"

@interface TraceLayerVC()
{
    AGSGraphicsLayer *hintLayer;
    
    TYTraceLayerV2 *traceLayer;
    TYSnappingManager *snappingManager;
    
    AGSGraphicsLayer *geometryLayer;
    
    
    AGSSimpleMarkerSymbol *originMarkerSymbol;
    AGSSimpleMarkerSymbol *snappedCoordinateSymbol;
    AGSSimpleMarkerSymbol *snappedVertexSymbol;
    
    AGSGraphicsLayer *testLayer;
}

@end

@implementation TraceLayerVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    originMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    snappedCoordinateSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    snappedVertexSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
    
    geometryLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:geometryLayer];
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor greenColor] width:2.0f];
    geometryLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sls];
    
    traceLayer = [[TYTraceLayerV2 alloc] initWithSpatialReference:self.mapView.spatialReference];
    [self.mapView addMapLayer:traceLayer];
    [traceLayer setFloor:self.currentMapInfo.floorNumber];
    
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
   
    
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    snappingManager = [[TYSnappingManager alloc] initWithBuilding:self.currentBuilding MapInfo:self.allMapInfos];
}


- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    NSLog(@"didFinishLoadingFloor");
    [traceLayer setFloor:mapInfo.floorNumber];
    
    AGSGeometry *route = [[snappingManager getRouteGeometries] objectForKey:@(mapInfo.floorNumber)];
    if (route) {
        [geometryLayer removeAllGraphics];
        [geometryLayer addGraphic:[AGSGraphic graphicWithGeometry:route symbol:nil attributes:nil]];
    }
    NSLog(@"%@", route);
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    
//    [hintLayer removeAllGraphics];
//    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
//    sms.size = CGSizeMake(5, 5);
//    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:sms attributes:nil]];
    
    
//    点击模拟轨迹点，测试轨迹层
    TYLocalPoint *lp = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];
    [traceLayer addTracePoint:lp];
//    [traceLayer showTraces];
    [traceLayer showSnappedTraces:snappingManager];
    
//    // 测试吸附功能
//    [testLayer removeAllGraphics];
//    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:originMarkerSymbol attributes:nil]];
//    
//    AGSPoint *sanppedPoint = [snappingManager getSnappedPoint:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.currentMapInfo.floorNumber]];
//    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:sanppedPoint symbol:snappedCoordinateSymbol attributes:nil]];
//     
//     AGSPoint *snappedVertex = [snappingManager getSnappedVertexResult:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.currentMapInfo.floorNumber]].point;
//    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:snappedVertex symbol:snappedVertexSymbol attributes:nil]];
}

@end
