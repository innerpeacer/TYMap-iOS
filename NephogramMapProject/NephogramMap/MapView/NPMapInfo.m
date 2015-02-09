//
//  NPMapInfo.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPMapInfo.h"


#define FILE_MAPINFO @"MapInfo_Building"

#define KEY_MAPINFOS @"MapInfo"

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

- (id)initWithMapID:(NSString *)mapID Extent:(MapExtent)e Size:(MapSize)s Floor:(NSString *)fs FloorIndex:(int)fi InitAngle:(double)initAngle
{
    self = [super init];
    if (self) {
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

+ (NSArray *)parseAllMapInfoForBuilding:(NSString *)buildingID
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    if (buildingID == nil) {
        return toReturn;
    }
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@", FILE_MAPINFO, buildingID] ofType:@"json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        NSDictionary *mapDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        NSArray *infoArray = [mapDict objectForKey:KEY_MAPINFOS];
        for (NSDictionary *infoDict in infoArray) {
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
            
            NPMapInfo *info = [[NPMapInfo alloc] initWithMapID:mapID Extent:SSMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:SSMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue InitAngle:initStr.doubleValue];
            
            [toReturn addObject:info];
        }
    }
    
    return toReturn;
}

+ (NPMapInfo *)parseMapInfo:(NSString *)floor ForBuilding:(NSString *)buildingID
{
    NPMapInfo *info = nil;
    
    if (floor == nil && buildingID == nil) {
        return info;
    }
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@", FILE_MAPINFO, buildingID] ofType:@"json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        NSDictionary *mapDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        NSArray *infoArray = [mapDict objectForKey:KEY_MAPINFOS];
        for (NSDictionary *infoDict in infoArray) {
            
            NSString *floorStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR];
            
            if ([floorStr isEqualToString:floor]) {
                NSString *mapID = [infoDict objectForKey:KEY_MAPINFO_MAPID];
                NSNumber *floorIndexStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR_INDEX];
                
                NSNumber *sizexStr = [infoDict objectForKey:KEY_MAPINFO_SIZEX];
                NSNumber *sizeyStr = [infoDict objectForKey:KEY_MAPINFO_SIZEY];
                
                NSNumber *initStr = [infoDict objectForKey:KEY_MAPINFO_INIT_ANGLE];
                
                NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
                NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
                NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
                NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];
                
                info = [[NPMapInfo alloc] initWithMapID:mapID Extent:SSMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:SSMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorIndex:floorIndexStr.intValue InitAngle:initStr.doubleValue];
                break;
            }
        }
    }
    
    return info;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MapID: %@, Floor: %@, Size: (%.2f, %.2f) Extent: (%.4f, %.4f, %.4f, %.4f)", _mapID, _floorName, _mapSize.x, _mapSize.y, _mapExtent.xmin, _mapExtent.ymin, _mapExtent.xmax, _mapExtent.ymax];
}

@end