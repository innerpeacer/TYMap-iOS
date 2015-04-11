//
//  NPMapInfo.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPMapInfo.h"
#import "NPMapFileManager.h"


#define KEY_MAPINFOS @"MapInfo"

#define KEY_MAPINFO_CITYID @"cityID"
#define KEY_MAPINFO_BUILDINGID @"buildingID"
#define KEY_MAPINFO_MAPID @"mapID"

#define KEY_MAPINFO_FLOOR @"floorName"
#define KEY_MAPINFO_FLOOR_INDEX @"floorIndex"


#define KEY_MAPINFO_SIZEX @"size_x"
#define KEY_MAPINFO_SIZEY @"size_y"

#define KEY_MAPINFO_INIT_ANGLE @"initAngle"

#define KEY_MAPINFO_XMIN @"xmin"
#define KEY_MAPINFO_XMAX @"xmax"
#define KEY_MAPINFO_YMIN @"ymin"
#define KEY_MAPINFO_YMAX @"ymax"

MapExtent SSMapExtentMake(double xmin, double ymin, double xmax, double ymax)
{
    MapExtent extent  = {xmin, ymin, xmax, ymax};
    return extent;
}

MapSize SSMapSizeMake(double x, double y)
{
    MapSize size = { x, y };
    return size;
}

@implementation NPMapInfo

- (id)initWithCityID:(NSString *)cityID BuildingID:(NSString *)buidlingID MapID:(NSString *)mapID Extent:(MapExtent)e Size:(MapSize)s Floor:(NSString *)fs FloorIndex:(int)fi InitAngle:(double)initAngle
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
        _initAngle = initAngle;
        _scalex = _mapSize.x / (_mapExtent.xmax - _mapExtent.xmin);
        _scaley = _mapSize.y / (_mapExtent.ymax - _mapExtent.ymin);
    }
    return self;
}

+ (NPMapInfo *)parseMapInfo:(NSString *)floor ForBuilding:(NPBuilding *)building
{
    NPMapInfo *info = nil;
    
    if (floor == nil || building == nil) {
        return info;
    }
    NSString *path = [NPMapFileManager getMapInfoJsonPath:building.cityID buildingID:building.buildingID];
    
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
                
                NSNumber *initStr = [infoDict objectForKey:KEY_MAPINFO_INIT_ANGLE];
                
                NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
                NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
                NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
                NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];
                
                info = [[NPMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:SSMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:SSMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue InitAngle:initStr.doubleValue];
                break;
            }
        }
    }
    return info;
}

+ (NSArray *)parseAllMapInfo:(NPBuilding *)building
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    if (building == nil) {
        return toReturn;
    }
    
    NSString *path = [NPMapFileManager getMapInfoJsonPath:building.cityID buildingID:building.buildingID];
    
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
            
            NSNumber *initStr = [infoDict objectForKey:KEY_MAPINFO_INIT_ANGLE];
            
            NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
            NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
            NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
            NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];
            
            NPMapInfo *info = [[NPMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:SSMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:SSMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue InitAngle:initStr.doubleValue];
            
            [toReturn addObject:info];
        }
    }
    
    return toReturn;
}

///**
// *  解析某建筑所有楼层的地图信息
// *
// *  @param buildingID 楼层所在建筑的ID
// *
// *  @return 所有楼层的地图信息数组:[NPMapInfo]
// */
//+ (NSArray *)parseAllMapInfoForBuilding:(NSString *)buildingID Path:(NSString *)path
//{
//    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
//    
//    if (buildingID == nil) {
//        return toReturn;
//    }
//    
//    NSError *error = nil;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        NSDictionary *mapDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//        
//        NSArray *infoArray = [mapDict objectForKey:KEY_MAPINFOS];
//        for (NSDictionary *infoDict in infoArray) {
//            NSString *cityID = [infoDict objectForKey:KEY_MAPINFO_CITYID];
//            NSString *buildingID = [infoDict objectForKey:KEY_MAPINFO_BUILDINGID];
//            NSString *mapID = [infoDict objectForKey:KEY_MAPINFO_MAPID];
//            NSString *floorStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR];
//            NSNumber *floorIndexStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR_INDEX];
//            
//            NSNumber *sizexStr = [infoDict objectForKey:KEY_MAPINFO_SIZEX];
//            NSNumber *sizeyStr = [infoDict objectForKey:KEY_MAPINFO_SIZEY];
//            
//            NSNumber *initStr = [infoDict objectForKey:KEY_MAPINFO_INIT_ANGLE];
//            
//            NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
//            NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
//            NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
//            NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];
//            
//            NPMapInfo *info = [[NPMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:SSMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:SSMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue InitAngle:initStr.doubleValue];
//            
//            [toReturn addObject:info];
//        }
//    }
//    
//    return toReturn;
//}

///**
// *  解析某楼层地图信息的静态方法
// *
// *  @param floor      楼层名称，如F1
// *  @param buildingID 楼层所在建筑的ID
// *
// *  @return 楼层地图信息
// */
//+ (NPMapInfo *)parseMapInfo:(NSString *)floor ForBuilding:(NSString *)buildingID Path:(NSString *)path
//{
//    NPMapInfo *info = nil;
//    
//    if (floor == nil && buildingID == nil) {
//        return info;
//    }
//    
//    NSError *error = nil;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        NSDictionary *mapDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//        
//        NSArray *infoArray = [mapDict objectForKey:KEY_MAPINFOS];
//        for (NSDictionary *infoDict in infoArray) {
//            
//            NSString *floorStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR];
//            
//            if ([floorStr isEqualToString:floor]) {
//                NSString *cityID = [infoDict objectForKey:KEY_MAPINFO_CITYID];
//                NSString *buildingID = [infoDict objectForKey:KEY_MAPINFO_BUILDINGID];
//                NSString *mapID = [infoDict objectForKey:KEY_MAPINFO_MAPID];
//                NSNumber *floorIndexStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR_INDEX];
//                
//                NSNumber *sizexStr = [infoDict objectForKey:KEY_MAPINFO_SIZEX];
//                NSNumber *sizeyStr = [infoDict objectForKey:KEY_MAPINFO_SIZEY];
//                
//                NSNumber *initStr = [infoDict objectForKey:KEY_MAPINFO_INIT_ANGLE];
//                
//                NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
//                NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
//                NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
//                NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];
//                
//                info = [[NPMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:SSMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:SSMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue InitAngle:initStr.doubleValue];
//                break;
//            }
//        }
//    }
//    return info;
//}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MapID: %@, Floor: %@, Size: (%.2f, %.2f) Extent: (%.4f, %.4f, %.4f, %.4f)", _mapID, _floorName, _mapSize.x, _mapSize.y, _mapExtent.xmin, _mapExtent.ymin, _mapExtent.xmax, _mapExtent.ymax];
}

@end