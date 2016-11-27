//
//  TraceLayerVC.m
//  MapProject
//
//  Created by innerpeacer on 2016/11/24.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "TraceLayerVC.h"
#import "TYUserDefaults.h"
#import "TYLitsoTraceLayer.h"
#import "TYSnappingManager.h"
#import <MKNetworkKit/MKNetworkKit.h>

@interface TraceLayerVC()
{
    AGSGraphicsLayer *hintLayer;
    
    TYLitsoTraceLayer *traceLayer;
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
    
    traceLayer = [[TYLitsoTraceLayer alloc] initWithSpatialReference:self.mapView.spatialReference];
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
    
    
////    点击模拟轨迹点，测试轨迹层
//    TYLocalPoint *lp = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];
//    [traceLayer addTracePoint:lp];
////    [traceLayer showTraces];
//    [traceLayer showSnappedTraces:snappingManager];
    
//    // 测试吸附功能
//    [testLayer removeAllGraphics];
//    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:originMarkerSymbol attributes:nil]];
//    
//    AGSPoint *sanppedPoint = [snappingManager getSnappedPoint:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.currentMapInfo.floorNumber]];
//    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:sanppedPoint symbol:snappedCoordinateSymbol attributes:nil]];
//     
//     AGSPoint *snappedVertex = [snappingManager getSnappedVertexResult:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.currentMapInfo.floorNumber]].point;
//    [testLayer addGraphic:[AGSGraphic graphicWithGeometry:snappedVertex symbol:snappedVertexSymbol attributes:nil]];
    
    
//    [self getTraceData];
    [self testTrace];
}

- (void)testTrace
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TraceData" ofType:@"json"]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    //        NSLog(@"%@", json);
    NSDictionary *traceData = json[@"Trace"];
    NSDictionary *themes = traceData[@"themes"];
    NSMutableDictionary *themeArray = [[NSMutableDictionary alloc] init];
    for (NSString *themeID in themes.allKeys) {
        NSDictionary *themeDict = themes[themeID];
        TYLocalPoint *lp = [TYLocalPoint pointWithX:[themeDict[@"x"] doubleValue] Y:[themeDict[@"y"] doubleValue] Floor:[themeDict[@"floor"] intValue]];
        [themeArray setObject:lp forKey:themeID];
    }
    
    NSArray *points = traceData[@"Points"];
    NSMutableArray *pointArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < points.count; ++i) {
        NSDictionary *pointDict = points[i];
        TYTraceLocalPoint *tp = [[TYTraceLocalPoint alloc] init];
        tp.location = [TYLocalPoint pointWithX:[pointDict[@"x"] doubleValue] Y:[pointDict[@"y"] doubleValue] Floor:[pointDict[@"floor"] intValue]];
        tp.inTheme = [pointDict[@"inTheme"] boolValue];
        tp.themeID = pointDict[@"themeID"];
        
        [pointArray addObject:tp];
    }
    
    NSLog(@"points: %d", (int)pointArray.count);
    NSLog(@"themes: %d", (int)themes.count);
    [traceLayer addTracePoints:pointArray WithThemes:themeArray];
    [traceLayer showSnappedTraces:snappingManager];
}

- (void)getTraceData
{
//    http://180.167.72.234:8082
//    /TYBLEGateway/extension/GetTrace
//    ?buildingID=00210025&customerID=F161124172807300&address=D375A82E9209&start=1480041717819
//    NSDictionary *params = @{@"buildingID": @"00210025", @"customerID": @"F161124172807300", @"address": @"D375A82E9209", @"start": @(1480041717819)};
    NSDictionary *params = @{@"buildingID": @"00210025", @"customerID": @"F161124172807300", @"address": @"D375A82E9209", @"start": @(1480041817819)};

    NSString *api = @"/TYBLEGateway/extension/GetTrace";
    NSString *host = @"180.167.72.234:8082";
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:host];
    MKNetworkOperation *op = [engine operationWithPath:api params:params httpMethod:@"GET"];
    NSLog(@"url: %@", [op url]);
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//                NSLog(@"%@", operation.responseString);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
//        NSLog(@"%@", json);
        NSDictionary *themes = json[@"themes"];
        NSMutableDictionary *themeArray = [[NSMutableDictionary alloc] init];
        for (NSString *themeID in themes.allKeys) {
            NSDictionary *themeDict = themes[themeID];
            TYLocalPoint *lp = [TYLocalPoint pointWithX:[themeDict[@"x"] doubleValue] Y:[themeDict[@"y"] doubleValue] Floor:[themeDict[@"floor"] intValue]];
            [themeArray setObject:lp forKey:themeID];
        }
        
        NSArray *points = json[@"Points"];
        NSMutableArray *pointArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < points.count; ++i) {
            NSDictionary *pointDict = points[i];
            TYTraceLocalPoint *tp = [[TYTraceLocalPoint alloc] init];
            tp.location = [TYLocalPoint pointWithX:[pointDict[@"x"] doubleValue] Y:[pointDict[@"y"] doubleValue] Floor:[pointDict[@"floor"] intValue]];
            tp.inTheme = [pointDict[@"inTheme"] boolValue];
            tp.themeID = pointDict[@"themeID"];
            
            [pointArray addObject:tp];
        }
        
        NSLog(@"points: %d", (int)pointArray.count);
        NSLog(@"themes: %d", (int)themes.count);
        [traceLayer addTracePoints:pointArray WithThemes:themes];
        [traceLayer showSnappedTraces:snappingManager];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                NSLog(@"%@", completedOperation.responseString);
        //        NSLog(@"%@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

@end
