//
//  NPPoi.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPPoi.h"

@interface NPPoi()
{
    
}


@end

@implementation NPPoi

+ (NPPoi *)poiWithGeoID:(NSString *)gid PoiID:(NSString *)pid FloorID:(NSString *)fid  BuildingID:(NSString *)bid Name:(NSString *)pname Geometry:(AGSGeometry *)geometry CategoryID:(int)cid Type:(POI_TYPE)ptype
{
    return [[NPPoi alloc] initWithGeoID:gid PoiID:pid FloorID:fid BuildingID:bid Name:pname Geometry:geometry CategoryID:cid Type:ptype];
}

- (id)initWithGeoID:(NSString *)gid PoiID:(NSString *)pid FloorID:(NSString *)fid  BuildingID:(NSString *)bid Name:(NSString *)pname Geometry:(AGSGeometry *)geometry CategoryID:(int)cid Type:(POI_TYPE)ptype
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
        _type = ptype;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GeoID: %@, PoiID: %@, Name: %@", _geoID, _poiID, _name];
}

@end
