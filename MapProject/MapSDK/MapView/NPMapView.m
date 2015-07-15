//
//  NPMapView.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPMapView.h"

#import "NPMapInfo.h"
#import "NPMapType.h"
#import "NPMapEnviroment.h"
#import "NPLocationLayer.h"
#import "NPMapFileManager.h"

#import "NPStructureGroupLayer.h"
#import "NPLabelGroupLayer.h"
#import "NPRouteLayer.h"
#import "NPRouteArrowLayer.h"
#import "NPAnimatedRouteArrowLayer.h"

#import "NPRouteHintLayer.h"
#import "NPBrand.h"

@interface NPMapView() <AGSMapViewTouchDelegate, AGSMapViewLayerDelegate, AGSCalloutDelegate>
{
    NPRenderingScheme *renderingScheme;
    
    NPStructureGroupLayer *structureGroupLayer;
    NPLabelGroupLayer *labelGroupLayer;
    
    NPLocationLayer *locationLayer;
    NPRouteLayer *routeLayer;
//    NPRouteArrowLayer *routeArrowLayer;
    NPAnimatedRouteArrowLayer *animatedRouteArrowLayer;
    NPRouteHintLayer *routeHintLayer;
    
    AGSEnvelope *initialEnvelope;
    NPMapViewMode mapViewMode;
    
    double currentDeviceHeading;
    double lastRotationAngle;
    
    NSDictionary *allBrandDict;
}

@end


@implementation NPMapView

- (void)reloadMapView
{
    if (self.currentMapInfo) {
        [structureGroupLayer loadContentsWithInfo:self.currentMapInfo];
        [labelGroupLayer loadContentsWithInfo:self.currentMapInfo];

        if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:didFinishLoadingFloor:)]) {
            [labelGroupLayer updateLabels];
            [self.mapDelegate NPMapView:self didFinishLoadingFloor:_currentMapInfo];
        }
    }
}

- (void)setFloorWithInfo:(NPMapInfo *)info
{
    
//    NSString* invalidDateString = @"20150811";
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMdd"];
//    NSDate* invalidDate = [dateFormatter dateFromString:invalidDateString];
//    NSTimeInterval interval = [invalidDate timeIntervalSinceDate:[NSDate date]];
//    if (interval < 0) {
//        NSLog(@"抱歉，SDK已过期");
//        return;
//    }
    
    if ([info.mapID isEqualToString:_currentMapInfo.mapID]) {
        return;
    }
    
    _currentMapInfo = info;

    [locationLayer removeAllGraphics];
    [routeLayer removeAllGraphics];
    [routeHintLayer removeAllGraphics];
    
//    [routeArrowLayer removeAllGraphics];
    [animatedRouteArrowLayer stopShowingArrow];
    
    [structureGroupLayer loadContentsWithInfo:info];
    [labelGroupLayer loadContentsWithInfo:info];

    if (initialEnvelope == nil) {
        initialEnvelope = [AGSEnvelope envelopeWithXmin:_currentMapInfo.mapExtent.xmin ymin:_currentMapInfo.mapExtent.ymin xmax:_currentMapInfo.mapExtent.xmax ymax:_currentMapInfo.mapExtent.ymax spatialReference:[NPMapEnvironment defaultSpatialReference]];
        [self zoomToEnvelope:initialEnvelope animated:NO];
        
        double width = 0.06; // 6cm
        self.minScale = _currentMapInfo.mapSize.x / width;
        self.maxScale = 6 / width;
    }
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:didFinishLoadingFloor:)]) {
        [labelGroupLayer updateLabels];
        [self.mapDelegate NPMapView:self didFinishLoadingFloor:_currentMapInfo];
    }
}

- (void)initMapViewWithBuilding:(NPBuilding *)b
{
    _building = b;
    NSString *renderingSchemePath = [NPMapFileManager getRenderingScheme:_building];
    renderingScheme = [[NPRenderingScheme alloc] initWithPath:(NSString *)renderingSchemePath];
    
    self.touchDelegate = self;
    self.layerDelegate = self;
    self.callout.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToZooming:) name:@"AGSMapViewDidEndZoomingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToPanning:) name:@"AGSMapViewDidEndPanningNotification" object:nil];
    
    [self setAllowRotationByPinching:YES];
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.gridLineWidth = 0.0;
        
    mapViewMode = NPMapViewModeDefault;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *brandArray = [NPBrand parseAllBrands:b];
    for (NPBrand *brand in brandArray) {
        [dict setObject:brand forKey:brand.poiID];
    }
    allBrandDict = dict;
    
    AGSSpatialReference *spatialReference = [NPMapEnvironment defaultSpatialReference];
    
    structureGroupLayer = [NPStructureGroupLayer structureLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:structureGroupLayer.floorLayer withName:LAYER_NAME_FLOOR];
    [self addMapLayer:structureGroupLayer.roomLayer withName:LAYER_NAME_ROOM];
    [self addMapLayer:structureGroupLayer.asserLayer withName:LAYER_NAME_ASSET];
    
    labelGroupLayer = [NPLabelGroupLayer labelGroupLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    labelGroupLayer.mapView = self;
    labelGroupLayer.labelLayer.brandDict = allBrandDict;
    [self addMapLayer:labelGroupLayer.facilityLayer withName:LAYER_NAME_FACILITY];
    [self addMapLayer:labelGroupLayer.labelLayer withName:LAYER_NAME_LABEL];
    
    routeLayer = [NPRouteLayer routeLayerWithSpatialReference:[NPMapEnvironment defaultSpatialReference]];
    routeLayer.mapView = self;
    [self addMapLayer:routeLayer];
    routeLayer.allowHitTest = NO;
    
    routeHintLayer = [NPRouteHintLayer routeHintLayerWithSpatialReference:[NPMapEnvironment defaultSpatialReference]];
    [self addMapLayer:routeHintLayer];
    routeHintLayer.allowHitTest = NO;
    
//    routeArrowLayer = [NPRouteArrowLayer routeArrowLayerWithSpatialReference:[NPMapEnvironment defaultSpatialReference]];
//    [self addMapLayer:routeArrowLayer];
//    routeArrowLayer.allowHitTest = NO;
    
    animatedRouteArrowLayer = [NPAnimatedRouteArrowLayer animatedRouteArrowLayerWithSpatialReference:[NPMapEnvironment defaultSpatialReference]];
    [self addMapLayer:animatedRouteArrowLayer];
    animatedRouteArrowLayer.allowHitTest = NO;

    locationLayer = [[NPLocationLayer alloc] initWithSpatialReference:spatialReference];
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

- (void)setMapMode:(NPMapViewMode)mode
{
    mapViewMode = mode;
    switch (mapViewMode) {
        case NPMapViewModeFollowing:
            [self setAllowRotationByPinching:NO];
            break;
            
        case NPMapViewModeDefault:
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

- (void)setRouteResult:(NPRouteResult *)result
{
    routeLayer.routeResult = result;
}

- (void)setRouteStart:(NPLocalPoint *)start
{
    routeLayer.startPoint = start;
}

- (void)setRouteEnd:(NPLocalPoint *)end
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

- (void)showRouteStartSymbolOnCurrentFloor:(NPLocalPoint *)sp
{
    [routeLayer showStartSymbol:sp];
}

- (void)showRouteEndSymbolOnCurrentFloor:(NPLocalPoint *)ep
{
    [routeLayer showEndSymbol:ep];
}

- (void)showRouteSwitchSymbolOnCurrentFloor:(NPLocalPoint *)sp
{
    [routeLayer showSwitchSymbol:sp];
}

- (void)setLocationSymbol:(TYMarkerSymbol *)symbol
{
    [locationLayer setLocationSymbol:symbol];
}

- (void)showLocation:(NPLocalPoint *)location
{
    [locationLayer removeAllGraphics];
    if (self.currentMapInfo.floorNumber == location.floor) {
        TYPoint *pos = [TYPoint pointWithX:location.x y:location.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
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
        case NPMapViewModeFollowing:
            self.rotationAngle = self.building.initAngle + currentDeviceHeading;
            break;
            
        case NPMapViewModeDefault:
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
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:didClickAtPoint:mapPoint:)]) {
        [self.mapDelegate NPMapView:self didClickAtPoint:screen mapPoint:(TYPoint *)mappoint];
    }
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:PoiSelected:)]) {
        NSArray *poiSelected = [self extractSelectedPoi:features];
        if (poiSelected.count > 0) {
            [self.mapDelegate NPMapView:self PoiSelected:poiSelected];
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
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapViewDidLoad:)]) {
        [self.mapDelegate NPMapViewDidLoad:self];
    }
}

- (void)calloutDidDismiss:(AGSCallout *)callout
{
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:calloutDidDismiss:)]) {
        [self.mapDelegate NPMapView:self calloutDidDismiss:(TYCallout *)callout];
    }
}

- (void)calloutWillDismiss:(AGSCallout *)callout
{
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:calloutWillDismiss:)]) {
        [self.mapDelegate NPMapView:self calloutWillDismiss:(TYCallout *)callout];
    }
}

//- (BOOL)callout:(AGSCallout *)callout willShowForLocationDisplay:(AGSLocationDisplay *)locationDisplay
//{
//    BOOL result = NO;
//    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:callout:willShowForLocationDisplay:)]) {
//        result = [self.mapDelegate NPMapView:self callout:(NPCallout *)callout willShowForLocationDisplay:(NPLocationDisplay *)locationDisplay];
//    }
//    return result;
//}

- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    BOOL result = NO;
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:willShowForGraphic:layer:mapPoint:)]) {
        TYGraphic *graphic = (TYGraphic *)feature;
        TYGraphicsLayer *graphicLayer = (TYGraphicsLayer *)layer;
        TYPoint *point = (TYPoint *)mapPoint;
        
        result = [self.mapDelegate NPMapView:self willShowForGraphic:graphic layer:graphicLayer mapPoint:point];
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
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_FACILITY];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ROOM]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ROOM];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ROOM];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ASSET]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ASSET];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(TYGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ASSET];
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

- (void)showRemainingRouteResultOnCurrentFloor:(NPLocalPoint *)lp
{
    NSArray *linesToShow = [routeLayer showRemainingRouteResultOnFloor:self.currentMapInfo.floorNumber WithLocation:lp];
    if (linesToShow && linesToShow.count > 0) {
//        [routeArrowLayer showRouteArrow:linesToShow];
        [animatedRouteArrowLayer showRouteArrow:linesToShow];
//        [animatedRouteArrowLayer showRouteArrow:linesToShow withTranslation:0.001];
    }
}



- (void)showRouteHintForDirectionHint:(NPDirectionalHint *)ds Centered:(BOOL)isCentered
{
    NPRouteResult *routeResult = routeLayer.routeResult;
    if (routeResult) {
        AGSPolyline *currentLine = ds.routePart.route;
        AGSPolyline *subLine = [NPRouteResult getSubPolyline:currentLine WithStart:ds.startPoint End:ds.endPoint];
        [routeHintLayer showRouteHint:subLine];
        
        if (isCentered) {
            AGSPoint *center = [AGSPoint pointWithX:(ds.startPoint.x + ds.endPoint.x)*0.5 y:(ds.startPoint.y + ds.endPoint.y)*0.5 spatialReference:[NPMapEnvironment defaultSpatialReference]];
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

- (NPPoi *)getPoiOnCurrentFloorWithPoiID:(NSString *)pid layer:(POI_LAYER)layer
{
    NPPoi *result = nil;
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

- (void)highlightPoi:(NPPoi *)poi
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
    for (NPPoi *poi in poiArray) {
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
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapViewDidZoomed:)]) {
        [self.mapDelegate NPMapViewDidZoomed:self];
    }
}

- (void)respondToPanning:(NSNotification *)notification
{
//    NSLog(@"respondToPanning: %f, %f", self.mapAnchor.x, self.mapAnchor.y);
    
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

- (NPPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y
{
    return [structureGroupLayer extractRoomPoiOnCurrentFloorWithX:x Y:y];
}

- (BOOL)updateRoomPOI:(NSString *)pid WithName:(NSString *)name
{
    BOOL structureUpdated = [structureGroupLayer updateRoomPOI:pid WithName:name];
    BOOL labelUpdated = [labelGroupLayer updateRoomLabel:pid WithName:name];
    
    return (structureUpdated && labelUpdated);
}

- (void)updateMapFiles
{
    NSString *labelFilePath = [NPMapFileManager getLabelLayerPath:self.currentMapInfo];
    AGSFeatureSet *lableSet = [labelGroupLayer getTextFeatureSet];
    
    NSDictionary *labelJsonDict = [lableSet encodeToJSON];
    NSData *labelData = [NSJSONSerialization dataWithJSONObject:labelJsonDict options:NSJSONWritingPrettyPrinted error:nil];
    [labelData writeToFile:labelFilePath atomically:YES];
    
    
    NSString *roomFilePath = [NPMapFileManager getRoomLayerPath:self.currentMapInfo];
    AGSFeatureSet *roomSet = [structureGroupLayer getRoomFeatureSet];
    
    NSDictionary *roomJsonDict = [roomSet encodeToJSON];
    NSData *roomData = [NSJSONSerialization dataWithJSONObject:roomJsonDict options:NSJSONWritingPrettyPrinted error:nil];
    [roomData writeToFile:roomFilePath atomically:YES];
}

- (void)dealloc
{
    if (animatedRouteArrowLayer) {
        [animatedRouteArrowLayer stopShowingArrow];
    }
}

@end