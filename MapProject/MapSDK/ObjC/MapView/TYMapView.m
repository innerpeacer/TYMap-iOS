//
//  TYMapView.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYMapView.h"

#import "TYMapInfo.h"
#import "TYMapType.h"
#import "TYMapEnviroment.h"
#import "TYLocationLayer.h"
#import "TYMapFileManager.h"

#import "TYStructureGroupLayer.h"
#import "TYLabelGroupLayer.h"
#import "TYRouteLayer.h"
#import "TYRouteArrowLayer.h"
#import "TYAnimatedRouteArrowLayer.h"

#import "TYRouteHintLayer.h"
#import "TYBrand.h"

#import "TYEncryption.h"
#import "TYLicenseValidation.h"

#import "TYMapFeatureData.h"

@interface TYMapView() <AGSMapViewTouchDelegate, AGSMapViewLayerDelegate, AGSCalloutDelegate>
{
    TYRenderingScheme *renderingScheme;
    
    TYStructureGroupLayer *structureGroupLayer;
    TYLabelGroupLayer *labelGroupLayer;
    
    TYLocationLayer *locationLayer;
    TYRouteLayer *routeLayer;

    TYAnimatedRouteArrowLayer *animatedRouteArrowLayer;
    TYRouteHintLayer *routeHintLayer;
    
    AGSEnvelope *initialEnvelope;
    TYMapViewMode mapViewMode;
    
    double currentDeviceHeading;
    double lastRotationAngle;
    
    NSDictionary *allBrandDict;
    
    NSDictionary *mapDataDict;
    
    NSString *userID;
    NSString *mapLicense;
}

@property (nonatomic, assign) BOOL autoCenterEnabled;

@end


@implementation TYMapView

- (void)enableAutoCenter
{
    _autoCenterEnabled = YES;
}

- (void)disableAutoCenter
{
    _autoCenterEnabled = NO;
}

- (void)reloadMapView
{
    if (self.currentMapInfo) {
        [self loadMapDataWithInfo:self.currentMapInfo];
        
        [structureGroupLayer loadContents:mapDataDict];
        [labelGroupLayer loadContents:mapDataDict];
        
//        [structureGroupLayer loadContentsWithInfo:self.currentMapInfo];
//        [labelGroupLayer loadContentsWithInfo:self.currentMapInfo];
        
        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:didFinishLoadingFloor:)]) {
            [labelGroupLayer updateLabels];
            [self.mapDelegate TYMapView:self didFinishLoadingFloor:_currentMapInfo];
        }
    }
}

- (void)readMapDataFromDBWithInfo:(TYMapInfo *)info
{
    TYMapFeatureData *featureData = [[TYMapFeatureData alloc] initWithBuilding:_building];
    mapDataDict = [featureData getAllMapDataOnFloor:info.floorNumber];
    
}

- (void)loadMapDataWithInfo:(TYMapInfo *)info
{
    NSString *dataPath = [TYMapFileManager getMapDataPath:info];
    NSError *error;
    NSString *jsonString;
    if ([TYMapEnvironment useEncryption]) {
        jsonString = [TYEncryption descriptFile:dataPath];
    } else {
        jsonString = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
    }
    
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        //        return;
    }
    
    NSDate *now = [NSDate date];
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    NSLog(@"Parse Time: %f", [[NSDate date] timeIntervalSinceDate:now]);
    
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    
    id object;
    object = [dict objectForKey:@"floor"];
    if ([object isKindOfClass:[NSString class]]) {
        [dataDict setObject:[[AGSFeatureSet alloc] init] forKey:@"floor"];
    } else {
        [dataDict setObject:[[AGSFeatureSet alloc] initWithJSON:[dict objectForKey:@"floor"]] forKey:@"floor"];
    }
    
    object = [dict objectForKey:@"room"];
    if ([object isKindOfClass:[NSString class]]) {
        [dataDict setObject:[[AGSFeatureSet alloc] init] forKey:@"room"];
    } else {
        [dataDict setObject:[[AGSFeatureSet alloc] initWithJSON:[dict objectForKey:@"room"]] forKey:@"room"];
    }
    
    object = [dict objectForKey:@"asset"];
    if ([object isKindOfClass:[NSString class]]) {
        [dataDict setObject:[[AGSFeatureSet alloc] init] forKey:@"asset"];
    } else {
        [dataDict setObject:[[AGSFeatureSet alloc] initWithJSON:[dict objectForKey:@"asset"]] forKey:@"asset"];
    }
    
    object = [dict objectForKey:@"facility"];
    if ([object isKindOfClass:[NSString class]]) {
        [dataDict setObject:[[AGSFeatureSet alloc] init] forKey:@"facility"];
    } else {
        [dataDict setObject:[[AGSFeatureSet alloc] initWithJSON:[dict objectForKey:@"facility"]] forKey:@"facility"];
    }
    
    object = [dict objectForKey:@"label"];
    if ([object isKindOfClass:[NSString class]]) {
        [dataDict setObject:[[AGSFeatureSet alloc] init] forKey:@"label"];
    } else {
        [dataDict setObject:[[AGSFeatureSet alloc] initWithJSON:[dict objectForKey:@"label"]] forKey:@"label"];
    }
    
    mapDataDict = [NSDictionary dictionaryWithDictionary:dataDict];
}

- (void)setFloorWithInfo:(TYMapInfo *)info
{
//    {
//        NSString* SDKInvalidDate = @"20170101";
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyyMMdd"];
//        NSDate* invalidDate = [dateFormatter dateFromString:SDKInvalidDate];
//        NSTimeInterval SDKInterval = [invalidDate timeIntervalSinceDate:[NSDate date]];
//        if (SDKInterval < 0) {
//            NSLog(@"SDK Expired");
//            return;
//        }
//    }
    
    BOOL licenseValidity = [TYLicenseValidation checkValidityWithUserID:userID License:mapLicense Building:_building];
    if (!licenseValidity) {
        NSLog(@"Invalid License!");
        return;
    }
    
    NSDate *expiredDate = [TYLicenseValidation evaluateLicenseWithUserID:userID License:mapLicense Building:_building];
    if (expiredDate == nil) {
        NSLog(@"Invalid License for Current Building!");
        return;
    }
    
    NSTimeInterval interval = [expiredDate timeIntervalSinceDate:[NSDate date]];
    if (interval < 0) {
        NSLog(@"License for Current Building is Expired!");
        NSLog(@"Expired Date: %@", expiredDate);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误！" message:@"抱歉，当前建筑的License已经过期！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if ([info.mapID isEqualToString:_currentMapInfo.mapID]) {
        return;
    }
    
    _currentMapInfo = info;
    
    [locationLayer removeAllGraphics];
    [routeLayer removeAllGraphics];
    [routeHintLayer removeAllGraphics];
    
    //    [routeArrowLayer removeAllGraphics];
    [animatedRouteArrowLayer stopShowingArrow];
    
    NSDate *now;
    BOOL usMapDB = false;
    usMapDB = true;
    if (usMapDB) {
        now = [NSDate date];
        [self readMapDataFromDBWithInfo:info];
        NSLog(@"Load Time For DB: %f", [[NSDate date] timeIntervalSinceDate:now]);
    } else {
        now = [NSDate date];
        [self loadMapDataWithInfo:info];
        NSLog(@"Load Time For Json: %f", [[NSDate date] timeIntervalSinceDate:now]);
    }
    

    


    [structureGroupLayer loadContents:mapDataDict];
    [labelGroupLayer loadContents:mapDataDict];
        
    if (initialEnvelope == nil) {
        initialEnvelope = [AGSEnvelope envelopeWithXmin:_currentMapInfo.mapExtent.xmin ymin:_currentMapInfo.mapExtent.ymin xmax:_currentMapInfo.mapExtent.xmax ymax:_currentMapInfo.mapExtent.ymax spatialReference:[TYMapEnvironment defaultSpatialReference]];
        [self zoomToEnvelope:initialEnvelope animated:NO];
        
//        double width = 0.06; // 6cm
//        self.minScale = _currentMapInfo.mapSize.x / width;
//        self.maxScale = 6 / width;
    }
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:didFinishLoadingFloor:)]) {
        [labelGroupLayer updateLabels];
        [self.mapDelegate TYMapView:self didFinishLoadingFloor:_currentMapInfo];
    }
}

- (void)switchBuilding:(TYBuilding *)b UserID:(NSString *)uID License:(NSString *)license
{
    _building = b;
    userID = uID;
    mapLicense = license;
    
    NSString *renderingSchemePath = [TYMapFileManager getRenderingScheme:_building];
    renderingScheme = [[TYRenderingScheme alloc] initWithPath:(NSString *)renderingSchemePath];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *brandArray = [TYBrand parseAllBrands:b];
    for (TYBrand *brand in brandArray) {
        [dict setObject:brand forKey:brand.poiID];
    }
    allBrandDict = dict;
    
    [structureGroupLayer setRenderingScheme:renderingScheme];
    [labelGroupLayer setRenderingScheme:renderingScheme];
}

- (void)initMapViewWithBuilding:(TYBuilding *)b UserID:(NSString *)uID License:(NSString *)license
{
    _autoCenterEnabled = YES;
    
    _building = b;
    userID = uID;
    mapLicense = license;
    
    NSString *renderingSchemePath = [TYMapFileManager getRenderingScheme:_building];
    renderingScheme = [[TYRenderingScheme alloc] initWithPath:(NSString *)renderingSchemePath];
    
    self.touchDelegate = self;
    self.layerDelegate = self;
    self.callout.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToZooming:) name:@"AGSMapViewDidEndZoomingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToPanning:) name:@"AGSMapViewDidEndPanningNotification" object:nil];
    
    [self setAllowRotationByPinching:YES];
    
    self.backgroundColor = [UIColor whiteColor];
    self.gridLineWidth = 0.0;
    
    mapViewMode = TYMapViewModeDefault;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *brandArray = [TYBrand parseAllBrands:b];
    for (TYBrand *brand in brandArray) {
        [dict setObject:brand forKey:brand.poiID];
    }
    allBrandDict = dict;
    
    AGSSpatialReference *spatialReference = [TYMapEnvironment defaultSpatialReference];
    
    structureGroupLayer = [TYStructureGroupLayer structureLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:structureGroupLayer.floorLayer withName:LAYER_NAME_FLOOR];
    [self addMapLayer:structureGroupLayer.roomLayer withName:LAYER_NAME_ROOM];
    [self addMapLayer:structureGroupLayer.assetLayer withName:LAYER_NAME_ASSET];
    
    labelGroupLayer = [TYLabelGroupLayer labelGroupLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    labelGroupLayer.mapView = self;
    labelGroupLayer.labelLayer.brandDict = allBrandDict;
    [self addMapLayer:labelGroupLayer.facilityLayer withName:LAYER_NAME_FACILITY];
    [self addMapLayer:labelGroupLayer.labelLayer withName:LAYER_NAME_LABEL];
    
    routeLayer = [TYRouteLayer routeLayerWithSpatialReference:[TYMapEnvironment defaultSpatialReference]];
    routeLayer.mapView = self;
    [self addMapLayer:routeLayer];
    routeLayer.allowHitTest = NO;
    
    routeHintLayer = [TYRouteHintLayer routeHintLayerWithSpatialReference:[TYMapEnvironment defaultSpatialReference]];
    [self addMapLayer:routeHintLayer];
    routeHintLayer.allowHitTest = NO;
    
    animatedRouteArrowLayer = [TYAnimatedRouteArrowLayer animatedRouteArrowLayerWithSpatialReference:[TYMapEnvironment defaultSpatialReference]];
    [self addMapLayer:animatedRouteArrowLayer];
    animatedRouteArrowLayer.allowHitTest = NO;
    
    locationLayer = [[TYLocationLayer alloc] initWithSpatialReference:spatialReference];
    [self addMapLayer:locationLayer withName:LAYER_NAME_LOCATION];
    locationLayer.allowHitTest = NO;
}

/**
 *  获取屏幕中心点对应的地图坐标
 *
 *  @return 公共设施类型数组:[NSNumber]
 */
- (TYPoint *)getPointForScreenCenter
{
    return (TYPoint *)self.mapAnchor;
}

- (void)setMapMode:(TYMapViewMode)mode
{
    mapViewMode = mode;
    switch (mapViewMode) {
        case TYMapViewModeFollowing:
            [self setAllowRotationByPinching:NO];
            break;
            
        case TYMapViewModeDefault:
            [self setAllowRotationByPinching:YES];
            self.rotationAngle = 0.0;
            break;
            
        default:
            break;
    }
}

- (void)setRouteStartSymbol:(TYPictureMarkerSymbol *)symbol
{
    routeLayer.startSymbol = symbol;
}

- (void)setRouteEndSymbol:(TYPictureMarkerSymbol *)symbol
{
    routeLayer.endSymbol = symbol;
}

- (void)setRouteSwitchSymbol:(TYPictureMarkerSymbol *)symbol
{
    routeLayer.switchSymbol = symbol;
}

- (void)setRouteResult:(TYRouteResult *)result
{
    routeLayer.routeResult = result;
}

- (void)setRouteStart:(TYLocalPoint *)start
{
    routeLayer.startPoint = start;
}

- (void)setRouteEnd:(TYLocalPoint *)end
{
    routeLayer.endPoint = end;
}

- (void)resetRouteLayer
{
    [routeLayer reset];
    [routeHintLayer removeAllGraphics];
    //    [routeArrowLayer removeAllGraphics];
    [animatedRouteArrowLayer stopShowingArrow];
}

- (void)clearRouteLayer
{
    [routeLayer removeAllGraphics];
    [routeHintLayer removeAllGraphics];
    //    [routeArrowLayer removeAllGraphics];
    [animatedRouteArrowLayer stopShowingArrow];
}

- (void)showRouteStartSymbolOnCurrentFloor:(TYLocalPoint *)sp
{
    [routeLayer showStartSymbol:sp];
}

- (void)showRouteEndSymbolOnCurrentFloor:(TYLocalPoint *)ep
{
    [routeLayer showEndSymbol:ep];
}

- (void)showRouteSwitchSymbolOnCurrentFloor:(TYLocalPoint *)sp
{
    [routeLayer showSwitchSymbol:sp];
}

- (void)setLocationSymbol:(TYMarkerSymbol *)symbol
{
    [locationLayer setLocationSymbol:symbol];
}

- (void)showLocation:(TYLocalPoint *)location
{
    [locationLayer removeAllGraphics];
    if (self.currentMapInfo.floorNumber == location.floor) {
        TYPoint *pos = [TYPoint pointWithX:location.x y:location.y spatialReference:[TYMapEnvironment defaultSpatialReference]];
        [locationLayer showLocation:pos withDeviceHeading:currentDeviceHeading initAngle:self.building.initAngle mapViewMode:mapViewMode];
    }
}

- (void)removeLocation
{
    [locationLayer removeLocation];
}

- (void)processDeviceRotation:(double)newHeading
{
    currentDeviceHeading = newHeading;
    [locationLayer updateDeviceHeading:newHeading initAngle:self.building.initAngle mapViewMode:mapViewMode];
    
    switch (mapViewMode) {
        case TYMapViewModeFollowing:
            self.rotationAngle = self.building.initAngle + currentDeviceHeading;
            break;
            
        case TYMapViewModeDefault:
            break;
            
        default:
            break;
    }
    
    if (fabs(lastRotationAngle - self.rotationAngle) > 10) {
        [labelGroupLayer updateLabels];
        lastRotationAngle = self.rotationAngle;
    }
}

/**
 *  以屏幕坐标为单位平移x、y距离
 *
 *  @param x x平移距离
 *  @param y y平移距离
 *  @param animated 是否使用动画
 */
- (void)translateInScreenUnitByX:(double)x Y:(double)y animated:(BOOL)animated
{
    CGPoint centerScreen = [self toScreenPoint:self.mapAnchor];
    CGPoint newCenterScreen = CGPointMake(centerScreen.x - x, centerScreen.y - y);
    AGSPoint *newCenter = [self toMapPoint:newCenterScreen];
    [self centerAtPoint:newCenter animated:animated];
}

/**
 *  以地图坐标为单位平移x、y距离
 *
 *  @param x        x平移距离
 *  @param y        y平移距离
 *  @param animated 是否使用动画
 */
- (void)translateInMapUnitByX:(double)x Y:(double)y animated:(BOOL)animated
{
    AGSPoint *center = self.mapAnchor;
    AGSPoint *newCenter = [AGSPoint pointWithX:center.x - x y:center.y - y spatialReference:self.spatialReference];
    [self centerAtPoint:newCenter animated:animated];
}

- (void)restrictLocation:(TYPoint *)location toScreenRange:(CGRect)range
{
    CGPoint locationOnScreen = [self toScreenPoint:location];
    if (CGRectContainsPoint(range, locationOnScreen)) {
        return;
    }
    
    double xOffset = 0;
    double yOffset = 0;
    
    if (locationOnScreen.x < range.origin.x) {
        xOffset = range.origin.x - locationOnScreen.x;
    }
    
    if (locationOnScreen.x > range.origin.x + range.size.width) {
        xOffset = range.origin.x + range.size.width - locationOnScreen.x;
    }
    
    if (locationOnScreen.y < range.origin.y) {
        yOffset = range.origin.y - locationOnScreen.y;
    }
    
    if (locationOnScreen.y > range.origin.y + range.size.height) {
        yOffset = range.origin.y + range.size.height - locationOnScreen.y;
    }
    
    [self translateInScreenUnitByX:xOffset Y:yOffset animated:YES];
}

- (void)clearSelection
{
    [structureGroupLayer clearSelection];
    [labelGroupLayer clearSelection];
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    //    NSLog(@"didClickAtPoint");
    [self clearSelection];
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:didClickAtPoint:mapPoint:)]) {
        [self.mapDelegate TYMapView:self didClickAtPoint:screen mapPoint:(TYPoint *)mappoint];
    }
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:PoiSelected:)]) {
        NSArray *poiSelected = [self extractSelectedPoi:features];
        if (poiSelected.count > 0) {
            [self.mapDelegate TYMapView:self PoiSelected:poiSelected];
        }
    }
    
    if (_highlightPOIOnSelection) {
        [self highlightPoiFeature:features];
    }
}


- (void)mapView:(AGSMapView *)mapView didMoveTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)mapView:(AGSMapView *)mapView didEndTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd));
    
}

- (void)mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd));
    
}

- (void)mapViewDidLoad:(AGSMapView *)mapView
{
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapViewDidLoad:)]) {
        [self.mapDelegate TYMapViewDidLoad:self];
    }
}

- (void)calloutDidDismiss:(AGSCallout *)callout
{
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:calloutDidDismiss:)]) {
        [self.mapDelegate TYMapView:self calloutDidDismiss:(TYCallout *)callout];
    }
}

- (void)calloutWillDismiss:(AGSCallout *)callout
{
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:calloutWillDismiss:)]) {
        [self.mapDelegate TYMapView:self calloutWillDismiss:(TYCallout *)callout];
    }
}

//- (BOOL)callout:(AGSCallout *)callout willShowForLocationDisplay:(AGSLocationDisplay *)locationDisplay
//{
//    BOOL result = NO;
//    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:callout:willShowForLocationDisplay:)]) {
//        result = [self.mapDelegate TYMapView:self callout:(TYCallout *)callout willShowForLocationDisplay:(TYLocationDisplay *)locationDisplay];
//    }
//    return result;
//}

- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    BOOL result = NO;
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapView:willShowForGraphic:layer:mapPoint:)]) {
        TYGraphic *graphic = (TYGraphic *)feature;
        TYGraphicsLayer *graphicLayer = (TYGraphicsLayer *)layer;
        TYPoint *point = (TYPoint *)mapPoint;
        
        result = [self.mapDelegate TYMapView:self willShowForGraphic:graphic layer:graphicLayer mapPoint:point];
    }
    return result;
}

- (NSArray *)extractSelectedPoi:(NSDictionary *)features
{
    NSMutableArray *poiArray = [NSMutableArray array];
    if ([features.allKeys containsObject:LAYER_NAME_FACILITY]) {
        NSArray *array = [features objectForKey:LAYER_NAME_FACILITY];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            TYPoi *poi = [TYPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_FACILITY];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ROOM]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ROOM];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            TYPoi *poi = [TYPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ROOM];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ASSET]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ASSET];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            TYPoi *poi = [TYPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ASSET];
            [poiArray addObject:poi];
        }
    }
    return poiArray;
}

- (void)highlightPoiFeature:(NSDictionary *)features
{
    //    if ([features.allKeys containsObject:LAYER_NAME_FACILITY]) {
    //        NSArray *array = [features objectForKey:LAYER_NAME_FACILITY];
    //        if (array != nil && array.count > 0) {
    //            AGSGraphic *graphic = (AGSGraphic *)array[0];
    //            [labelGroupLayer setFacilitySelected:YES forGraphic:graphic];
    //
    //        }
    //        return;
    //    }
    
    //    if ([features.allKeys containsObject:LAYER_NAME_ASSET]) {
    //        NSArray *array = [features objectForKey:LAYER_NAME_ASSET];
    //        if (array != nil && array.count > 0) {
    //            AGSGraphic *graphic = (AGSGraphic *)array[0];
    //            [assetLayer setSelected:YES forGraphic:graphic];
    //        }
    //        return;
    //    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ROOM]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ROOM];
        if (array != nil && array.count > 0) {
            AGSGraphic *graphic = (AGSGraphic *)array[0];
            [structureGroupLayer setRoomSelected:YES forGraphic:graphic];
        }
        return;
    }
    
}

- (void)showRouteResultOnCurrentFloor
{
    NSArray *linesToShow = [routeLayer showRouteResultOnFloor:self.currentMapInfo.floorNumber];
    if (linesToShow && linesToShow.count > 0) {
        //        [routeArrowLayer showRouteArrow:linesToShow];
        [animatedRouteArrowLayer showRouteArrow:linesToShow];
        //        [animatedRouteArrowLayer showRouteArrow:linesToShow withTranslation:0.001];
    }
}

- (void)showRemainingRouteResultOnCurrentFloor:(TYLocalPoint *)lp
{
    NSArray *linesToShow = [routeLayer showRemainingRouteResultOnFloor:self.currentMapInfo.floorNumber WithLocation:lp];
    if (linesToShow && linesToShow.count > 0) {
        //        [routeArrowLayer showRouteArrow:linesToShow];
        [animatedRouteArrowLayer showRouteArrow:linesToShow];
        //        [animatedRouteArrowLayer showRouteArrow:linesToShow withTranslation:0.001];
    }
}

- (void)showRouteHintForDirectionHint:(TYDirectionalHint *)ds Centered:(BOOL)isCentered
{
    TYRouteResult *routeResult = routeLayer.routeResult;
    if (routeResult) {
        AGSPolyline *currentLine = ds.routePart.route;
        AGSPolyline *subLine = [TYRouteResult getSubPolyline:currentLine WithStart:ds.startPoint End:ds.endPoint];
        [routeHintLayer showRouteHint:subLine];
        
        if (isCentered) {
            AGSPoint *center = [AGSPoint pointWithX:(ds.startPoint.x + ds.endPoint.x)*0.5 y:(ds.startPoint.y + ds.endPoint.y)*0.5 spatialReference:[TYMapEnvironment defaultSpatialReference]];
            [self centerAtPoint:center animated:YES];
        }
    }
}

- (void)showAllFacilitiesOnCurrentFloor
{
    [labelGroupLayer showAllFacilities];
}

- (void)showFacilityOnCurrentWithCategory:(int)categoryID
{
    [labelGroupLayer showFacilityWithCategory:categoryID];
}

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs
{
    [labelGroupLayer showFacilityOnCurrentWithCategorys:categoryIDs];
}

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor
{
    return [labelGroupLayer getAllFacilityCategoryIDOnCurrentFloor];
}

- (TYPoi *)getPoiOnCurrentFloorWithPoiID:(NSString *)pid layer:(POI_LAYER)layer
{
    TYPoi *result = nil;
    switch (layer) {
        case POI_ROOM:
            result = [structureGroupLayer getRoomPoiWithPoiID:pid];
            break;
            
        case POI_FACILITY:
            result = [labelGroupLayer getFacilityPoiWithPoiID:pid];
            break;
            
        default:
            break;
    }
    return result;
}

- (void)highlightPoi:(TYPoi *)poi
{
    switch (poi.layer) {
        case POI_ROOM:
            [structureGroupLayer highlightRoomPoi:poi.poiID];
            break;
            
        case POI_FACILITY:
            [labelGroupLayer highlightFacilityPoi:poi.poiID];
            break;
            
        default:
            break;
    }
}

- (void)highlightPois:(NSArray *)poiArray
{
    for (TYPoi *poi in poiArray) {
        [self highlightPoi:poi];
    }
}

//#define DEFAULT_RESOLUTION_THRESHOLD 0.1

// 一般按5个字算，屏幕占距1cm，6m的房间内可以显示
//#define DEFAULT_SCALE_THRESHOLD 600


#define DEFAULT_SCALE_THRESHOLD 1000

- (void)respondToZooming:(NSNotification *)notification
{
    [labelGroupLayer updateLabels];
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(TYMapViewDidZoomed:)]) {
        [self.mapDelegate TYMapViewDidZoomed:self];
    }
}

- (void)respondToPanning:(NSNotification *)notification
{
    //    NSLog(@"respondToPanning: %f, %f", self.mapAnchor.x, self.mapAnchor.y);
    if (_autoCenterEnabled) {
        AGSPoint *center = self.mapAnchor;
        
        double x = center.x;
        double y = center.y;
        
        if (x <= _currentMapInfo.mapExtent.xmax && x >= _currentMapInfo.mapExtent.xmin && y <= _currentMapInfo.mapExtent.ymax && y >= _currentMapInfo.mapExtent.ymin) {
            return;
        }
        
        x = (x > _currentMapInfo.mapExtent.xmax) ? _currentMapInfo.mapExtent.xmax : ((x < _currentMapInfo.mapExtent.xmin) ? _currentMapInfo.mapExtent.xmin : x);
        y = (y > _currentMapInfo.mapExtent.ymax) ? _currentMapInfo.mapExtent.ymax : ((y < _currentMapInfo.mapExtent.ymin) ? _currentMapInfo.mapExtent.ymin : y);
        
        [self centerAtPoint:[AGSPoint pointWithX:x y:y spatialReference:self.spatialReference] animated:YES];
    }
}

- (TYPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y
{
    return [structureGroupLayer extractRoomPoiOnCurrentFloorWithX:x Y:y];
}


//  更新ROOM层目标POI的名称信息
//
//  @param pid  目标POI的ID
//  @param name 修改后的名称
//
//  @return 是否修改成功

//- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name
//{
//    BOOL structureUpdated = [structureGroupLayer updateRoomPOI:pid WithName:name];
//    BOOL labelUpdated = [labelGroupLayer updateRoomLabel:pid WithName:name];
//    
//    return (structureUpdated && labelUpdated);
//}



//将修改结果更新至地图文件中
- (void)updateMapFiles
{
//    NSString *labelFilePath = [TYMapFileManager getLabelLayerPath:self.currentMapInfo];
//    AGSFeatureSet *lableSet = [labelGroupLayer getTextFeatureSet];
//    
//    NSDictionary *labelJsonDict = [lableSet encodeToJSON];
//    NSData *labelData = [NSJSONSerialization dataWithJSONObject:labelJsonDict options:NSJSONWritingPrettyPrinted error:nil];
//    [labelData writeToFile:labelFilePath atomically:YES];
//    
//    
//    NSString *roomFilePath = [TYMapFileManager getRoomLayerPath:self.currentMapInfo];
//    AGSFeatureSet *roomSet = [structureGroupLayer getRoomFeatureSet];
//    
//    NSDictionary *roomJsonDict = [roomSet encodeToJSON];
//    NSData *roomData = [NSJSONSerialization dataWithJSONObject:roomJsonDict options:NSJSONWritingPrettyPrinted error:nil];
//    [roomData writeToFile:roomFilePath atomically:YES];
}

- (void)dealloc
{
    if (animatedRouteArrowLayer) {
        [animatedRouteArrowLayer stopShowingArrow];
    }
}

@end