//
//  CppOfflineMapRouteVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "CppOfflineMapRouteVC.h"

#import "TYOfflineRouteManager.h"

#import "IPRouteLayer.h"
#import "TYMapEnviroment.h"
#import "IPRoutePointConverter.h"
#import "TYDirectionalHint.h"

#import "TYRouteResult.h"
#import "TYUserDefaults.h"

#import "FMDatabase.h"

@interface CppOfflineMapRouteVC()<TYOfflineRouteManagerDelegate>
{
    // 路径管理器
    TYOfflineRouteManager *cppOfflineRouteManager;
    
    TYLocalPoint *startLocalPoint;
    TYLocalPoint *endLocalPoint;
    
    BOOL isRouting;
    
    // 路径规划结果
    TYRouteResult *routeResult;
    TYRoutePart *currentRoutePart;
    NSArray *routeGuides;
    
    AGSGraphicsLayer *hintLayer;
    AGSGraphicsLayer *testLayer;
    
    // 起点、终点、切换点标识符号
    AGSPictureMarkerSymbol *startSymbol;
    AGSPictureMarkerSymbol *endSymbol;
    AGSPictureMarkerSymbol *switchSymbol;
    AGSSimpleMarkerSymbol *markerSymbol;
    
    NSDate *startDate;
    NSDate *endDate;
}

@end

@implementation CppOfflineMapRouteVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    [self initSymbols];
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    testLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:testLayer];
    
    
    AGSGraphicsLayer *poiLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:poiLayer];
    
    AGSPictureMarkerSymbol *poiSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@""];
    AGSPoint *poiCoord = [AGSPoint pointWithX:0 y:0 spatialReference:self.mapView.spatialReference];
    [poiLayer addGraphic:[AGSGraphic graphicWithGeometry:poiCoord symbol:poiSymbol attributes:nil]];
    
    
    NSDate *now = [NSDate date];
    cppOfflineRouteManager = [TYOfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    cppOfflineRouteManager.delegate = self;
    NSLog(@"加载用时：%f", [[NSDate date] timeIntervalSinceDate:now]);
    
//    [self test];
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    endDate = [NSDate date];
    NSLog(@"导航用时：%f", [endDate timeIntervalSinceDate:startDate]);
    
    [hintLayer removeAllGraphics];
    [testLayer removeAllGraphics];
    
    routeResult = rs;
    
    [self.mapView setRouteResult:rs];
    [self.mapView setRouteStart:startLocalPoint];
    [self.mapView setRouteEnd:endLocalPoint];
    [self.mapView showRouteResultOnCurrentFloor];
    
    NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.currentMapInfo.floorNumber];
    if (routePartArray && routePartArray.count > 0) {
        currentRoutePart = [routePartArray objectAtIndex:0];
    }
    
    if (currentRoutePart) {
        routeGuides = [routeResult getRouteDirectionalHint:currentRoutePart];
    }
//    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(rotateMap) userInfo:nil repeats:YES];
//    [self.mapView setMapMode:TYMapViewModeFollowing];

}

//- (void)rotateMap
//{
//    NSLog(@"rotateMap");
//    static int angle = 0;
//    [self.mapView processDeviceRotation:angle++];
//}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}


- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);

    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
    
    startLocalPoint = endLocalPoint;
    endLocalPoint = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:self.mapView.currentMapInfo.floorNumber];;
    [self requestRoute];
}

- (void)test
{
    NSString *poiDBPath = [[TYMapEnvironment getBuildingDirectory:self.currentBuilding] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_POI.db", self.currentBuilding.buildingID]];
    FMDatabase *db = [FMDatabase databaseWithPath:poiDBPath];
    [db open];
    
    NSString *sql = @"select * from poi";
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        NSString *poiID = [rs stringForColumn:@"POI_ID"];
        if ([poiID isEqualToString:@"053200001F0110053"]) {
            double x = [rs doubleForColumn:@"LABEL_X"];
            double y = [rs doubleForColumn:@"LABEL_Y"];
            int floor = [rs intForColumn:@"FLOOR_INDEX"];
            startLocalPoint = [TYLocalPoint pointWithX:x Y:y Floor:floor];
        }
        
        if ([poiID isEqualToString:@"053200001F0110079"]) {
            double x = [rs doubleForColumn:@"LABEL_X"];
            double y = [rs doubleForColumn:@"LABEL_Y"];
            int floor = [rs intForColumn:@"FLOOR_INDEX"];
            endLocalPoint = [TYLocalPoint pointWithX:x Y:y Floor:floor];
        }
    }
    [db close];
    [self requestRoute];
}

- (void)requestRoute
{
    if (startLocalPoint == nil || endLocalPoint == nil) {
        return;
    }
    routeResult = nil;
    isRouting = YES;
    
    startDate = [NSDate date];
//    startPoint = new TYLocalPoint(13275974.30287264, 2989071.967726886, 3);
//    endPoint = new TYLocalPoint(13275987.1889, 2989087.670699999, 3);
    [cppOfflineRouteManager requestRouteWithStart:startLocalPoint End:endLocalPoint];
}

- (void)initSymbols
{
    startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    
    markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
}

@end
