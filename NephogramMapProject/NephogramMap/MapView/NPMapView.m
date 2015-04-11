//
//  NPMapView.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPMapView.h"

#import "NPAssetLayer.h"
#import "NPFacilityLayer.h"
#import "NPLabelLayer.h"
#import "NPRoomLayer.h"
#import "NPFloorLayer.h"
#import "NPMapView.h"
#import "NPMapInfo.h"
#import "NPMapType.h"
#import "NPMapEnviroment.h"
#import "NPLocationLayer.h"
#import "NPMapFileManager.h"

@interface NPMapView() <AGSMapViewTouchDelegate, AGSMapViewLayerDelegate, AGSCalloutDelegate>
{
    NPRenderingScheme *renderingScheme;
    
    NPFloorLayer *floorLayer;
    NPAssetLayer *assetLayer;
    NPFacilityLayer *facilityLayer;
    NPLabelLayer *labelLayer;
    NPRoomLayer *roomLayer;
    NPLocationLayer *locationLayer;
    
    AGSEnvelope *initialEnvelope;
    
    NPMapViewMode mapViewMode;
    
    double currentDeviceHeading;
}

@end


@implementation NPMapView

- (void)setFloorWithInfo:(NPMapInfo *)info
{
    
    if ([info.mapID isEqualToString:_currentMapInfo.mapID]) {
        return;
    }
    
    _currentMapInfo = info;
    
    [floorLayer removeAllGraphics];
    [roomLayer removeAllGraphics];
    [assetLayer removeAllGraphics];
    [facilityLayer removeAllGraphics];
    [labelLayer removeAllGraphics];
    [locationLayer removeAllGraphics];
    
    
    [floorLayer loadContentsWithInfo:info];
    [roomLayer loadContentsWithInfo:info];
    [assetLayer loadContentsWithInfo:info];
    [facilityLayer loadContentsWithInfo:info];
    [labelLayer loadContentsWithInfo:info];
    

    if (initialEnvelope == nil) {
        initialEnvelope = [AGSEnvelope envelopeWithXmin:_currentMapInfo.mapExtent.xmin ymin:_currentMapInfo.mapExtent.ymin xmax:_currentMapInfo.mapExtent.xmax ymax:_currentMapInfo.mapExtent.ymax spatialReference:[NPMapEnvironment defaultSpatialReference]];
        [self zoomToEnvelope:initialEnvelope animated:NO];
        
//        self.maxResolution = (_currentMapInfo.mapSize.x * 1.5 / (720/2.0));
        double width = 0.06; // 6cm
        self.minScale = _currentMapInfo.mapSize.x / width;
        self.maxScale = 6 / width;
    }
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:didFinishLoadingFloor:)]) {
        [self.mapDelegate NPMapView:self didFinishLoadingFloor:_currentMapInfo];
    }
}

//- (void)initMapViewWithRenderScheme:(NPRenderingScheme *)aRenderingScheme
- (void)initMapViewWithBuilding:(NPBuilding *)b
{
//    renderingScheme = aRenderingScheme;
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
    
//    self.minResolution = (7.2 / (720/2.0));
    
    mapViewMode = NPMapViewModeDefault;
    
    AGSSpatialReference *spatialReference = [NPMapEnvironment defaultSpatialReference];
    
    floorLayer = [NPFloorLayer floorLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:floorLayer withName:LAYER_NAME_FLOOR];
    floorLayer.allowHitTest = NO;
    
    roomLayer = [NPRoomLayer roomLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:roomLayer withName:LAYER_NAME_ROOM];
    roomLayer.selectionSymbol = renderingScheme.defaultHighlightFillSymbol;
    
    assetLayer = [NPAssetLayer assetLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:assetLayer withName:LAYER_NAME_ASSET];
    
    facilityLayer = [NPFacilityLayer facilityLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:facilityLayer withName:LAYER_NAME_FACILITY];
    facilityLayer.selectionColor = [UIColor cyanColor];
    
    labelLayer = [NPLabelLayer labelLayerWithSpatialReference:spatialReference];
    [self addMapLayer:labelLayer withName:LAYER_NAME_LABEL];
    labelLayer.allowHitTest = NO;
    
    locationLayer = [[NPLocationLayer alloc] initWithSpatialReference:spatialReference];
    [self addMapLayer:locationLayer withName:LAYER_NAME_LOCATION];
    locationLayer.allowHitTest = NO;
}

/**
 *  获取屏幕中心点对应的地图坐标
 *
 *  @return 公共设施类型数组:[NSNumber]
 */
- (NPPoint *)getPointForScreenCenter
{
    return (NPPoint *)self.mapAnchor;
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

- (void)setLocationSymbol:(NPMarkerSymbol *)symbol
{
    [locationLayer setLocationSymbol:symbol];
}

- (void)showLocation:(NPLocalPoint *)location
{
    [locationLayer removeAllGraphics];
    if (self.currentMapInfo.floorNumber == location.floor) {
        NPPoint *pos = [NPPoint pointWithX:location.x y:location.y spatialReference:[NPMapEnvironment defaultSpatialReference]];
        [locationLayer showLocation:pos withDeviceHeading:currentDeviceHeading initAngle:self.currentMapInfo.initAngle mapViewMode:mapViewMode];
    }
}

- (void)removeLocation
{
    [locationLayer removeLocation];
}

- (void)processDeviceRotation:(double)newHeading
{
    currentDeviceHeading = newHeading;
    [locationLayer updateDeviceHeading:newHeading initAngle:self.currentMapInfo.initAngle mapViewMode:mapViewMode];
    
    switch (mapViewMode) {
        case NPMapViewModeFollowing:
            self.rotationAngle = self.currentMapInfo.initAngle + currentDeviceHeading;
            break;
            
        case NPMapViewModeDefault:
            break;
            
        default:
            break;
    }
}

/**
 *  以屏幕坐标为单位平移x、y距离
 *
 *  @param x x平移距离
 *  @param y y平移距离
 *
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
 *  @param x x平移距离
 *  @param y y平移距离
 *
 */
- (void)translateInMapUnitByX:(double)x Y:(double)y animated:(BOOL)animated
{
    AGSPoint *center = self.mapAnchor;
    AGSPoint *newCenter = [AGSPoint pointWithX:center.x - x y:center.y - y spatialReference:self.spatialReference];
    [self centerAtPoint:newCenter animated:animated];
}

- (void)restrictLocation:(NPPoint *)location toScreenRange:(CGRect)range
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
    [roomLayer clearSelection];
    //    [assetLayer clearSelection];
    [facilityLayer clearSelection];
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    //    NSLog(@"didClickAtPoint");
    [self clearSelection];
    
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:didClickAtPoint:mapPoint:)]) {
        [self.mapDelegate NPMapView:self didClickAtPoint:screen mapPoint:(NPPoint *)mappoint];
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
        [self.mapDelegate NPMapView:self calloutDidDismiss:(NPCallout *)callout];
    }
}

- (void)calloutWillDismiss:(AGSCallout *)callout
{
    if (self.mapDelegate && [self.mapDelegate respondsToSelector:@selector(NPMapView:calloutWillDismiss:)]) {
        [self.mapDelegate NPMapView:self calloutWillDismiss:(NPCallout *)callout];
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
        NPGraphic *graphic = (NPGraphic *)feature;
        NPGraphicsLayer *graphicLayer = (NPGraphicsLayer *)layer;
        NPPoint *point = (NPPoint *)mapPoint;
        
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
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(NPGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_FACILITY];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ROOM]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ROOM];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(NPGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ROOM];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ASSET]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ASSET];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:(NPGeometry *)graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Layer:POI_ASSET];
            [poiArray addObject:poi];
        }
    }
    return poiArray;
}

- (void)highlightPoiFeature:(NSDictionary *)features
{
    if ([features.allKeys containsObject:LAYER_NAME_FACILITY]) {
        NSArray *array = [features objectForKey:LAYER_NAME_FACILITY];
        if (array != nil && array.count > 0) {
            AGSGraphic *graphic = (AGSGraphic *)array[0];
            [facilityLayer setSelected:YES forGraphic:graphic];
        }
        return;
    }
    
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
            [roomLayer setSelected:YES forGraphic:graphic];
        }
        return;
    }
    
}

- (void)showAllFacilitiesOnCurrentFloor
{
    [facilityLayer showAllFacilities];
}

- (void)showFacilityOnCurrentWithCategory:(int)categoryID
{
    [facilityLayer showFacilityWithCategory:categoryID];
}

- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs
{
    [facilityLayer showFacilityOnCurrentWithCategorys:categoryIDs];
}

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor
{
    return [facilityLayer getAllFacilityCategoryIDOnCurrentFloor];
}

- (NPPoi *)getPoiOnCurrentFloorWithPoiID:(NSString *)pid layer:(POI_LAYER)layer
{
    NPPoi *result = nil;
    switch (layer) {
        case POI_ROOM:
            result = [roomLayer getPoiWithPoiID:pid];
            break;
            
        case POI_FACILITY:
            result = [facilityLayer getPoiWithPoiID:pid];
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
            [roomLayer highlightPoi:poi.poiID];
            break;
            
        case POI_FACILITY:
            [facilityLayer highlightPoi:poi.poiID];
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
//    NSLog(@"respondToZooming: %f", self.resolution);
//    BOOL labelVisible = self.resolution < DEFAULT_RESOLUTION_THRESHOLD;
    BOOL labelVisible = self.mapScale < DEFAULT_SCALE_THRESHOLD;
    [labelLayer setVisible:labelVisible];
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
    return [roomLayer extractPoiOnCurrentFloorWithX:x Y:y];
}

@end

