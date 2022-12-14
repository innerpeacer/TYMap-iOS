//
//  TYPoi.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYPoi.h"

@interface TYPoi()
{
    
}

@end

@implementation TYPoi

+ (TYPoi *)poiWithGeoID:(NSString *)gid PoiID:(NSString *)pid FloorID:(NSString *)fid  BuildingID:(NSString *)bid Name:(NSString *)pname Geometry:(AGSGeometry *)geometry CategoryID:(int)cid Layer:(POI_LAYER)pLayer
{
    return [[TYPoi alloc] initWithGeoID:gid PoiID:pid FloorID:fid BuildingID:bid Name:pname Geometry:geometry CategoryID:cid Layer:pLayer];
}

- (id)initWithGeoID:(NSString *)gid PoiID:(NSString *)pid FloorID:(NSString *)fid  BuildingID:(NSString *)bid Name:(NSString *)pname Geometry:(AGSGeometry *)geometry CategoryID:(int)cid Layer:(POI_LAYER)pLayer
{
    self = [super init];
    if (self) {
        _geoID = gid;
        _poiID = pid;
        _floorID = fid;
        _buildingID = bid;
        _name = pname;
        _geometry = geometry;
        _categoryID = cid;
        _layer = pLayer;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GeoID: %@, PoiID: %@, Name: %@, Layer: %d", _geoID, _poiID, _name, _layer];
}

@end
