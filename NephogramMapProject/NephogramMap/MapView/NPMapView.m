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

#import "NPMapEnviroment.h"

#define LAYER_NAME_FLOOR @"FloorLayer"
#define LAYER_NAME_ROOM @"RoomLayer"
#define LAYER_NAME_ASSET @"AssetLayer"
#define LAYER_NAME_FACILITY @"FacilityLayer"
#define LAYER_NAME_LABEL @"LabelLayer"

#define GRAPHIC_ATTRIBUTE_GEO_ID @"GEO_ID"
#define GRAPHIC_ATTRIBUTE_POI_ID @"POI_ID"
#define GRAPHIC_ATTRIBUTE_FLOOR_ID @"FLOOR_ID"
#define GRAPHIC_ATTRIBUTE_BUILDING_ID @"BUILDING_ID"
#define GRAPHIC_ATTRIBUTE_NAME @"NAME"
#define GRAPHIC_ATTRIBUTE_CATEGORY_ID @"CATEGORY_ID"
#define GRAPHIC_ATTRIBUTE_FLOOR @"FLOOR"

@interface NPMapView() <AGSMapViewTouchDelegate>
{
    NPRenderingScheme *renderingScheme;
    
    NPFloorLayer *floorLayer;
    NPAssetLayer *assetLayer;
    NPFacilityLayer *facilityLayer;
    NPLabelLayer *labelLayer;
    NPRoomLayer *roomLayer;
    
    //    NPMapInfo *currentMapInfo;
}

@end


@implementation NPMapView

- (void)setFloorWithInfo:(NPMapInfo *)info
{
    
    if ([info.mapID isEqualToString:_currentMapInfo.mapID]) {
        return;
    }
    
    _currentMapInfo = info;

    [floorLayer loadContentsWithInfo:info];
    [roomLayer loadContentsWithInfo:info];
    [assetLayer loadContentsWithInfo:info];
    [facilityLayer loadContentsWithInfo:info];
    [labelLayer loadContentsWithInfo:info];
    
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:_currentMapInfo.mapExtent.xmin ymin:_currentMapInfo.mapExtent.ymin xmax:_currentMapInfo.mapExtent.xmax ymax:_currentMapInfo.mapExtent.ymax spatialReference:[NPMapEnvironment defaultSpatialReference]];
    [self zoomToEnvelope:envelope animated:NO];
}

- (void)initMapViewWithRenderScheme:(NPRenderingScheme *)aRenderingScheme
{
    renderingScheme = aRenderingScheme;
    
    self.touchDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToZooming:) name:@"AGSMapViewDidEndZoomingNotification" object:nil];
    
    
    [self setAllowRotationByPinching:YES];
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.gridLineWidth = 0.0;
    
    AGSSpatialReference *spatialReference = [NPMapEnvironment defaultSpatialReference];
    
    floorLayer = [NPFloorLayer floorLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:floorLayer withName:LAYER_NAME_FLOOR];
    floorLayer.allowHitTest = NO;
    
    roomLayer = [NPRoomLayer roomLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:roomLayer withName:LAYER_NAME_ROOM];
//    roomLayer.selectionSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor cyanColor] outlineColor:[UIColor cyanColor]];
    roomLayer.selectionSymbol = renderingScheme.defaultHighlightFillSymbol;
    
    assetLayer = [NPAssetLayer assetLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:assetLayer withName:LAYER_NAME_ASSET];
    //    assetLayer.selectionSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor cyanColor] outlineColor:[UIColor cyanColor]];
    
    facilityLayer = [NPFacilityLayer facilityLayerWithRenderingScheme:renderingScheme SpatialReference:spatialReference];
    [self addMapLayer:facilityLayer withName:LAYER_NAME_FACILITY];
    facilityLayer.selectionColor = [UIColor cyanColor];
    
    
    labelLayer = [NPLabelLayer labelLayerWithSpatialReference:spatialReference];
    [self addMapLayer:labelLayer withName:LAYER_NAME_LABEL];
    labelLayer.allowHitTest = NO;
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
        [self.mapDelegate NPMapView:self didClickAtPoint:screen mapPoint:mappoint];
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


- (NSArray *)extractSelectedPoi:(NSDictionary *)features
{
    NSMutableArray *poiArray = [NSMutableArray array];
    if ([features.allKeys containsObject:LAYER_NAME_FACILITY]) {
        NSArray *array = [features objectForKey:LAYER_NAME_FACILITY];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Type:POI_FACILITY];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ROOM]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ROOM];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Type:POI_ROOM];
            [poiArray addObject:poi];
        }
    }
    
    if ([features.allKeys containsObject:LAYER_NAME_ASSET]) {
        NSArray *array = [features objectForKey:LAYER_NAME_ASSET];
        for (int i = 0; i < array.count; ++i) {
            AGSGraphic *graphic = (AGSGraphic *)array[i];
            
            NPPoi *poi = [NPPoi poiWithGeoID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_GEO_ID] PoiID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_POI_ID] FloorID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_FLOOR_ID] BuildingID:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_BUILDING_ID] Name:[graphic attributeForKey:GRAPHIC_ATTRIBUTE_NAME] Geometry:graphic.geometry CategoryID:[[graphic attributeForKey:GRAPHIC_ATTRIBUTE_CATEGORY_ID] intValue] Type:POI_ASSET];
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

- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor
{
    return [facilityLayer getAllFacilityCategoryIDOnCurrentFloor];
}

#define DEFAULT_RESOLUTION_THRESHOLD 0.1
- (void)respondToZooming:(NSNotification *)notification
{
    NSLog(@"respondToZooming: %f", self.resolution);
    BOOL labelVisible = self.resolution < DEFAULT_RESOLUTION_THRESHOLD;
    [labelLayer setVisible:labelVisible];
}

@end

