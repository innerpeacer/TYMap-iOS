//
//  TYMapInfo.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYMapInfo.h"
#import "TYMapFileManager.h"
#import <TYMapData/TYMapData.h>

#define KEY_MAPINFOS @"MapInfo"

#define KEY_MAPINFO_CITYID @"cityID"
#define KEY_MAPINFO_BUILDINGID @"buildingID"
#define KEY_MAPINFO_MAPID @"mapID"

#define KEY_MAPINFO_FLOOR @"floorName"
#define KEY_MAPINFO_FLOOR_INDEX @"floorIndex"


#define KEY_MAPINFO_SIZEX @"size_x"
#define KEY_MAPINFO_SIZEY @"size_y"

#define KEY_MAPINFO_XMIN @"xmin"
#define KEY_MAPINFO_XMAX @"xmax"
#define KEY_MAPINFO_YMIN @"ymin"
#define KEY_MAPINFO_YMAX @"ymax"

MapExtent TYMapExtentMake(double xmin, double ymin, double xmax, double ymax)
{
    MapExtent extent  = {xmin, ymin, xmax, ymax};
    return extent;
}

MapSize TYMapSizeMake(double x, double y)
{
    MapSize size = { x, y };
    return size;
}

@implementation TYMapInfo

- (id)initWithCityID:(NSString *)cityID BuildingID:(NSString *)buidlingID MapID:(NSString *)mapID Extent:(MapExtent)e Size:(MapSize)s Floor:(NSString *)fs FloorIndex:(int)fi
{
    self = [super init];
    if (self) {
        _cityID = cityID;
        _buildingID = buidlingID;
        _mapID = mapID;
        _mapExtent = e;
        _mapSize = s;
        _floorName = fs;
        _floorNumber = fi;
        _scalex = _mapSize.x / (_mapExtent.xmax - _mapExtent.xmin);
        _scaley = _mapSize.y / (_mapExtent.ymax - _mapExtent.ymin);
    }
    return self;
}

+ (TYMapInfo *)parseMapInfo:(NSString *)floor ForBuilding:(TYBuilding *)building
{
    TYMapInfo *info = nil;
    
    if (floor == nil || building == nil) {
        return info;
    }
    NSString *path = [TYMapFileManager getMapInfoJsonPath:building.cityID buildingID:building.buildingID];
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *mapDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        NSArray *infoArray = [mapDict objectForKey:KEY_MAPINFOS];
        for (NSDictionary *infoDict in infoArray) {
            
            NSString *floorStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR];
            
            if ([floorStr isEqualToString:floor]) {
                NSString *cityID = [infoDict objectForKey:KEY_MAPINFO_CITYID];
                NSString *buildingID = [infoDict objectForKey:KEY_MAPINFO_BUILDINGID];
                NSString *mapID = [infoDict objectForKey:KEY_MAPINFO_MAPID];
                NSNumber *floorIndexStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR_INDEX];
                
                NSNumber *sizexStr = [infoDict objectForKey:KEY_MAPINFO_SIZEX];
                NSNumber *sizeyStr = [infoDict objectForKey:KEY_MAPINFO_SIZEY];
                
                NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
                NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
                NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
                NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];
                
                info = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:TYMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue];
                break;
            }
        }
    }
    return info;
}

+ (NSArray *)parseAllMapInfo:(TYBuilding *)building
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    if (building == nil) {
        return toReturn;
    }
    
    NSString *path = [TYMapFileManager getMapInfoJsonPath:building.cityID buildingID:building.buildingID];
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *mapDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        NSArray *infoArray = [mapDict objectForKey:KEY_MAPINFOS];
        for (NSDictionary *infoDict in infoArray) {
            NSString *cityID = [infoDict objectForKey:KEY_MAPINFO_CITYID];
            NSString *buildingID = [infoDict objectForKey:KEY_MAPINFO_BUILDINGID];
            NSString *mapID = [infoDict objectForKey:KEY_MAPINFO_MAPID];
            NSString *floorStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR];
            NSNumber *floorIndexStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR_INDEX];
            
            NSNumber *sizexStr = [infoDict objectForKey:KEY_MAPINFO_SIZEX];
            NSNumber *sizeyStr = [infoDict objectForKey:KEY_MAPINFO_SIZEY];
            
            NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
            NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
            NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
            NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];
            
            TYMapInfo *info = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:TYMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue];
            
            [toReturn addObject:info];
        }
    }
    
    return toReturn;
}

+ (TYMapInfo *)searchMapInfoFromArray:(NSArray *)array Floor:(int)floor
{
    for (TYMapInfo *info in array) {
        if (floor == info.floorNumber) {
            return info;
        }
    }
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MapID: %@, Floor: %@, Size: (%.2f, %.2f) Extent: (%.4f, %.4f, %.4f, %.4f)", _mapID, _floorName, _mapSize.x, _mapSize.y, _mapExtent.xmin, _mapExtent.ymin, _mapExtent.xmax, _mapExtent.ymax];
}

@end