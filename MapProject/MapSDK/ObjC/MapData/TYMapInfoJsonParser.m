//
//  TYMapInfoJsonParser.m
//  MapProject
//
//  Created by innerpeacer on 15/10/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYMapInfoJsonParser.h"
#import "TYMapFileManager.h"

#define KEY_MAPINFOS @"MapInfo"

#define KEY_MAPINFO_CITYID @"cityID"
#define KEY_MAPINFO_BUILDINGID @"buildingID"
#define KEY_MAPINFO_MAPID @"mapID"

#define KEY_MAPINFO_FLOOR @"floorName"
#define KEY_MAPINFO_FLOOR_INDEX @"floorNumber"


#define KEY_MAPINFO_SIZEX @"size_x"
#define KEY_MAPINFO_SIZEY @"size_y"

#define KEY_MAPINFO_XMIN @"xmin"
#define KEY_MAPINFO_XMAX @"xmax"
#define KEY_MAPINFO_YMIN @"ymin"
#define KEY_MAPINFO_YMAX @"ymax"

@implementation TYMapInfoJsonParser

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
                NSNumber *floorNumberStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR_INDEX];

                NSNumber *sizexStr = [infoDict objectForKey:KEY_MAPINFO_SIZEX];
                NSNumber *sizeyStr = [infoDict objectForKey:KEY_MAPINFO_SIZEY];

                NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
                NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
                NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
                NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];

                info = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:TYMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorNumber:floorNumberStr.intValue];
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
            NSNumber *floorNumberStr = [infoDict objectForKey:KEY_MAPINFO_FLOOR_INDEX];

            NSNumber *sizexStr = [infoDict objectForKey:KEY_MAPINFO_SIZEX];
            NSNumber *sizeyStr = [infoDict objectForKey:KEY_MAPINFO_SIZEY];

            NSNumber *xminStr = [infoDict objectForKey:KEY_MAPINFO_XMIN];
            NSNumber *xmaxStr = [infoDict objectForKey:KEY_MAPINFO_XMAX];
            NSNumber *yminStr = [infoDict objectForKey:KEY_MAPINFO_YMIN];
            NSNumber *ymaxStr = [infoDict objectForKey:KEY_MAPINFO_YMAX];

            TYMapInfo *info = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:TYMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorNumber:floorNumberStr.intValue];

            [toReturn addObject:info];
        }
    }

    return toReturn;
}

+ (NSArray *)parseAllMapInfoFromFile:(NSString *)path
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];

    if (path == nil) {
        return toReturn;
    }

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

            TYMapInfo *info = [[TYMapInfo alloc] initWithCityID:cityID BuildingID:buildingID MapID:mapID Extent:TYMapExtentMake(xminStr.doubleValue, yminStr.doubleValue, xmaxStr.doubleValue, ymaxStr.doubleValue) Size:TYMapSizeMake(sizexStr.doubleValue, sizeyStr.doubleValue) Floor:floorStr FloorNumber:floorIndexStr.intValue];

            [toReturn addObject:info];
        }
    }

    return toReturn;
}

@end
